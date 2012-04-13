//
// Copyright: Katalyst Interactive 2011
//
// Author: Haydn Ewers <haydn@katalyst.com.au>
//

package au.com.katalyst.events
{

  import flash.events.Event;

  public class VideoPlayerEvent extends Event
  {


    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Constants                                                                            Constants //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//

    public static const BUFFER_FULL:String = "bufferFull";

    public static const ON_META_DATA:String = "onMetaData";

    public static const PLAYBACK_STARTED:String = "playbackStarted";

    public static const PLAYBACK_HALTED:String = "playbackHalted";

    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Constructor                                                                        Constructor //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//


    public function VideoPlayerEvent(type:String, url:String)
    {
      super(type);

      _url = url;
    }


    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Properties                                                                          Properties //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // url
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    protected var _url:String;

    public function get url():String
    {
      return _url;
    }


    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Variables                                                                            Variables //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//


    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Methods                                                                                Methods //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//


    /**
     * Creates a clone of the event for propagation purposes.
     *
     * @return A copy of the event.
     */
    override public function clone():Event
    {
      return new VideoPlayerEvent(type, url);
    }

    /**
     * @return A string representation of the event.
     */
    override public function toString():String
    {
      return formatToString("VideoPlayerEvent", "type", "bubbles", "cancelable", "eventPhase", "url");
    }


    //------------------------------------------------------------------------------------------------//
    //                                                                                                //
    // Event Handlers                                                                  Event Handlers //
    //                                                                                                //
    //------------------------------------------------------------------------------------------------//


  }

}