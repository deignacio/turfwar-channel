package com.litl.sdk.richinput.remotehandler {
    import com.litl.sdk.richinput.IRemoteControl;

    /**
     * defines the interface for an object to represent a
     * remote control or player in a channel.
     *
     * this object should be created using a IRemoteHandlerFactory
     *
     * @see IRemoteHandlerFactory
     * @see RemoteHandlerManager
     */
    public interface IRemoteHandler {
        /**
         * perform any pairing logic for this handler,
         * such as connecting to the remote's acceleromter
         * and creating an AccelerometerKeypad object, or
         * just general on connect type of initialization
         *
         * @see IRemoteControl
         * @see AccelerometerKeypad
         */
        function pair(remote:IRemoteControl):void;

        /**
         * perform any unpairing logic for this handler,
         * such as removing any AccelerometerKeypads
         * or any other sort of disconnect type of stuff
         */
        function unpair(remote:IRemoteControl):void;
    }
}
