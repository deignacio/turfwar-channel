package com.litl.sdk.richinput.remotehandler {
    /**
    * Defines a factory interface for objects to be used
    * with the RemoteHandlerManager to maintain
    * and track connected remote control objects
    *
    * @see RemoteHandlerManager
    * @see IRemoteHandler
    * @see IRemoteControl
    */
    public interface IRemoteHandlerFactory {
        /** create the new IRemoteHandler object */
        function createHandler():IRemoteHandler;

        /** the class of the objects being created */
        function get klass():Class;
    }
}
