package com.litl.sdk.richinput.remotehandler {
    import com.litl.sdk.event.RemoteStatusEvent;
    import com.litl.sdk.service.LitlService;

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.richinput.RemoteManager;

    /**
     * developers should not have to deal with managing the list of remotes
     * connected and disconnected to the channel.  there is a lot of common
     * code that will be duplicated (and potentially incorrectly) by all
     * channels using a remote.  this helper class is meant to serve as a
     * clear guideline of a good pattern to use when interacting with remotes
     * as players in a game
     */
    public class RemoteHandlerManager extends EventDispatcher {
        protected var service:LitlService;
        protected var remoteManager:RemoteManager;
        protected var factory:IRemoteHandlerFactory;

        protected var remoteIds:Array;
        protected var handlers:Dictionary;

        /**
         * constructor
         *
         * @param service the litl service
         * @param factory an IRemoteHandlerFactory to use for connected remotes
         * @param target an optional event dispatcher target
         *
         * @see IRemoteHandlerFactory
         */
        public function RemoteHandlerManager(service:LitlService, factory:IRemoteHandlerFactory, target:IEventDispatcher=null) {
            super(target);

            remoteIds = new Array();
            handlers = new Dictionary();

            this.service = service;
            this.factory = factory;
            remoteManager = new RemoteManager(service);
        }

        /**
         * connects to the remote manager and begins listening for RemoteStatusEvent events
         */
        public function start():void {
            remoteManager.addEventListener(RemoteStatusEvent.REMOTE_STATUS, handleRemoteStatus);
        }

        /**
         * disconnects from the remote manager, stops listening for RemoteStatusEvents
         */
        public function stop():void {
            remoteManager.addEventListener(RemoteStatusEvent.REMOTE_STATUS, handleRemoteStatus);
        }

        /**
         * stops the remote manager, and removes all references to existing handlers and the service
         */
        public function destroy():void {
            // not sure if i want to destroy all handlers or not, unsure
            stop();
            remoteManager = null;
            service = null;
            remoteIds = null;
        }

        /**
         * a convenience method for performing an operation on all remote handlers currently
         * connected.
         *
         * the signature of the callback function is:
         *
         * function(handler:IRemoteHandler):void
         */
        public function forEachHandler(func:Function):void {
            var outerFunc:Function = function(remoteId:String, index:int, arr:Array):void {
                var handler:IRemoteHandler = handlers[remoteId] as IRemoteHandler;
                func(handler);
            };
            remoteIds.forEach(outerFunc);
        }

        /** the number of remotes currently connected */
        public function get numConnected():int {
            return remoteIds.length;
        }

        private function handleRemoteStatus(e:RemoteStatusEvent):void {
            var remote:IRemoteControl = e.remote;
            if (remote != null) {
                if (e.remoteEnabled) {
                    handleRemoteConnect(remote);
                } else {
                    handleRemoteDisconnect(remote);
                }
            }

            onRemoteStatus(remote);
            dispatchEvent(e);
        }

        /**
         * override me when you want code run to handle a remote status event
         * regardless of remoteEnabled value.
         *
         * if you want to run logic for only en/dis-abled remotes, override
         * onRemoteConnected and onRemoteDisconnected methods, respectively.
         *
         * note:  onRemoteStatus is executed _after_ onRemoteConnected and
         * onRemoteDisconnected
         *
         * @param remote  the remote object that changed
         *
         * @see IRemoteControl
         */
        protected function onRemoteStatus(remote:IRemoteControl):void {
        }

        private function handleRemoteConnect(remote:IRemoteControl):void {
            if (remoteIds.indexOf(remote.id) == -1) {
                remoteIds.push(remote.id);

                var handler:IRemoteHandler = handlers[remote.id] as IRemoteHandler;
                if (handler == null) {
                    handler = factory.createHandler();
                    handlers[remote.id] = handler;
                }

                handler.pair(remote);
            }
            onRemoteConnected(remote, handler);
        }

        /**
         * override me when you want code run to handle a remote control
         * that just connected
         *
         * if you want to run logic for only enabled remotes, override
         * onRemoteDisconnected, otherwise try onRemoteStatus
         *
         * note:  onRemoteStatus is executed _after_ onRemoteConnected and
         * onRemoteDisconnected
         *
         * @param remote  the remote object that connected
         * @param handler  the IRemoteHandler object created for this remote
         *
         * @see IRemoteControl
         * @see IRemoteHandler
         */
        protected function onRemoteConnected(remote:IRemoteControl, handler:IRemoteHandler):void {
        }

        private function handleRemoteDisconnect(remote:IRemoteControl):void {
            remoteIds.splice(remoteIds.indexOf(remote.id), 1);

            var handler:IRemoteHandler = handlers[remote.id] as IRemoteHandler;
            if (handler != null) {
                handler.unpair(remote);
                // leave the handler around so that if it returns we don't lose state
            }

            onRemoteDisconnected(remote, handler);
        }

        /**
         * override me when you want code run to handle a remote control
         * that just disconnected
         *
         * if you want to run logic for only enabled remotes, override
         * onRemoteConnected, otherwise try onRemoteStatus
         *
         * note:  onRemoteStatus is executed _after_ onRemoteConnected and
         * onRemoteDisconnected
         *
         * @param remote  the remote object that connected
         * @param handler  the IRemoteHandler object created for this remote
         *
         * @see IRemoteControl
         * @see IRemoteHandler
         */
        protected function onRemoteDisconnected(remote:IRemoteControl, handler:IRemoteHandler):void {
        }
    }
}
