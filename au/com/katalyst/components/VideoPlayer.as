//
// Copyright: Katalyst Interactive 2011
//
// Author: Haydn Ewers <haydn@katalyst.com.au>
//

package au.com.katalyst.components
{

  import au.com.katalyst.events.VideoPlayerEvent;

  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.AsyncErrorEvent;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.NetStatusEvent;
  import flash.events.SecurityErrorEvent;
  import flash.media.SoundTransform;
  import flash.media.Video;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  import flash.ui.Keyboard;

  public class VideoPlayer extends Sprite
  {

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Constants                                                                            Constants //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Constructor                                                                        Constructor //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    public function VideoPlayer(width:int, height:int)
    {
      super();

      _bufferTime = 1;
      connection = new NetConnection();
      _hasMetaData = false;
      freezeLastFrame = false;
      fillingBuffer = false;
      _isPlaying = false;
      _isStreaming = false;
      loop = false;
      video = new Video();
      _volume = 1;

      video.height = height;
      video.width = width;

      addChild(video);

      addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
      addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
      connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
      connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
    }

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Properties                                                                          Properties //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // bufferTime
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _bufferTime:Number;

    public function get bufferTime():int
    {
      return _bufferTime;
    }

    public function set bufferTime(value:int):void
    {
      _bufferTime = value;
      if (stream) stream.bufferTime = value;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // debug
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _debug:Boolean;

    public function get debug():Boolean
    {
      return _debug;
    }

    public function set debug(value:Boolean):void
    {
      _debug = value;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // duration
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public function get duration():Number
    {
      return hasMetaData ? metaData.duration : 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // hasMetaData
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _hasMetaData:Boolean;

    public function get hasMetaData():Boolean
    {
      return _hasMetaData;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // isPlaying
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _isPlaying:Boolean;

    public function get isPlaying():Boolean
    {
      return _isPlaying;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // isStreaming
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * This is different to <code>isPlaying</code> in that a video can be paused whilst still streaming.
     */
    protected var _isStreaming:Boolean;

    public function get isStreaming():Boolean
    {
      return _isStreaming;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // loadProgress
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * Where 1 is 100% loaded and 0 is nothing loaded at all.
     */
    public function get loadProgress():Number
    {
      return stream ? stream.bytesLoaded/stream.bytesTotal : 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // metaData
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _metaData:Object;

    public function get metaData():Object
    {
      return _metaData;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // playbackProgress
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * A number between 0 and 1 indicating the playback progress.
     */
    public function get playbackProgress():Number
    {
      return (stream && hasMetaData) ? stream.time/metaData.duration : 0;
    }

    public function set playbackProgress(value:Number):void
    {
      if (stream)
      {
        value = Math.min(1, Math.max(0, value));

        if (loadProgress < value) stream.seek(Math.max(0, loadProgress*metaData.duration-bufferTime));
        else stream.seek(value*metaData.duration);
      }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // time
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public function get time():Number
    {
      return stream ? stream.time : 0;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // videoHeight
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public function get videoHeight():int
    {
      return video.height;
    }

    public function set videoHeight(value:int):void
    {
      video.height = value;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // videoWidth
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public function get videoWidth():int
    {
      return video.width;
    }

    public function set videoWidth(value:int):void
    {
      video.width = value;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // volume
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _volume;

    public function get volume():Number
    {
      return _volume;
    }

    public function set volume(value:Number):void
    {
      _volume = value;

      if (stream) stream.soundTransform = new SoundTransform(value);
    }

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Variables                                                                            Variables //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    protected var connection:NetConnection;

    public var freezeLastFrame:Boolean;

    protected var fillingBuffer:Boolean;

    public var loop:Boolean;

    protected var stream:NetStream;

    protected var video:Video;

    protected var url:String;

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Methods                                                                                Methods //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    protected function connectStream():void
    {
      if (debug) trace(this, "connectStream");

      stream = new NetStream(connection);
      stream.bufferTime = bufferTime;
      stream.client = this;

      video.attachNetStream(stream);

      stream.play(url);

      video.visible = false;
      stream.soundTransform = new SoundTransform(0);

      stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
      stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
    }

    public function fillBuffer():void
    {
      if (debug) trace(this, "fillBuffer");

      if (url && !_isStreaming)
      {
        connection.connect(null);
        _isStreaming = true;
        fillingBuffer = true;
      }
    }

    public function pause():void
    {
      if (debug) trace(this, "pause");

      stream.pause();
      _isPlaying = false;

      dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.PLAYBACK_HALTED, url));
    }

    public function play():void
    {
      if (debug) trace(this, "play");

      if (url)
      {
        if (!_isStreaming)
        {
          connection.connect(null);
          _isStreaming = true;
        }
        else
        {
          stream.resume();
        }

        fillingBuffer = false;
        _isPlaying = true;

        dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.PLAYBACK_STARTED, url));
      }
    }

    public function setVideo(url:String):void
    {
      if (debug) trace(this, "setVideo");

      if (url != this.url)
      {
        if (isStreaming) stop();
        this.url = url;
      }
    }

    public function stop():void
    {
      if (debug) trace(this, "stop");

      if (stream) stream.close();
      _isStreaming = false;
      _isPlaying = false;

      video.visible = false;
      stream.soundTransform = new SoundTransform(0);

      dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.PLAYBACK_HALTED, url));
    }

    public function toggle():void
    {
      if (debug) trace(this, "toggle");

      if (isPlaying) pause();
      else play();
    }

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Event Handlers                                                                  Event Handlers //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    protected function addedToStageHandler(event:Event):void
    {
      if (stage) stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, false, 0, true);
    }

    protected function asyncErrorHandler(event:AsyncErrorEvent):void
    {
      if (debug) trace("asyncErrorHandler: "+event);
/*      stop();*/
    }

    protected function netStatusHandler(event:NetStatusEvent):void
    {
      if (debug) trace(this, "netStatusHandler");
      if (debug) trace("\t", "event.info.code", event.info.code);

      switch (event.info.code)
      {
        case "NetConnection.Connect.Success":
        {
          connectStream();
          break;
        }
        case "NetStream.Play.StreamNotFound":
        {
          if (debug) trace("Unable to locate video: "+url);
          stop();
          break;
        }
        case "NetStream.Play.Stop":
        {
          if (loop) stream.seek(0);
          else
          {
            if (freezeLastFrame) pause();
            else stop();
          }
          break;
        }
        case "NetStream.Buffer.Full":
        {
          video.visible = true;
          stream.soundTransform = new SoundTransform(volume);

          if (fillingBuffer)
          {
            stream.pause();
            stream.seek(0);
            fillingBuffer = false;
          }

          dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.BUFFER_FULL, url));
          break;
        }
      }

      dispatchEvent(event);
    }

    public function onCuePoint(data:Object):void
    {
      //
    }

    public function onImageData(data:Object):void
    {
      //
    }

    public function onMetaData(data:Object):void
    {
      if (debug) trace(this, "onMetaData");

      _metaData = data;
      _hasMetaData = true;

      if (debug) trace("\t", "data.duration", data.duration);
      // TODO: Dispatch an event. VideoPlayerEvent.RECEIVED_META_DATA.
    }

    public function onPlayStatus(data:Object):void
    {
      //
    }

    public function onTextData(data:Object):void
    {
      //
    }

    public function onXMPData(data:Object):void
    {
      //
    }

    protected function removedFromStageHandler(event:Event):void
    {
      if (stage) stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
    }

    protected function securityErrorHandler(event:SecurityErrorEvent):void
    {
      if (debug) trace("securityErrorHandler: "+event);
      stop();
    }

    protected function stageKeyDownHandler(event:KeyboardEvent):void
    {
      if (event.keyCode == Keyboard.SPACE) toggle();
    }

  }

}