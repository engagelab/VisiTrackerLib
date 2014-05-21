package
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class ObjectRemover extends EventDispatcher {
		
		public static const SESSION_DELETED:String = "SESSION_DELETED";
		public static const EVENT_DELETED:String = "EVENT_DELETED";
		
		private var session:Object;
		private var eventObject:Object;
		private var endpoint:String;
		private var sessionId:String;
		private	var deleteObjectRequest:URLRequest;
		private	var uploader:URLLoader;
		private var token:String;
		
		public function ObjectRemover(endpoint:String, token:String) {
			this.endpoint = endpoint;
			this.token = token;
		}
		
		public function removeSession(sessionId:String):void {
			this.sessionId = sessionId;
			deleteObjectRequest = new URLRequest(endpoint + "/session/" +sessionId+ "?token="+token);
			deleteObjectRequest.method = URLRequestMethod.DELETE;
			uploader = new URLLoader();
			uploader.addEventListener(Event.COMPLETE, handleSessionServiceResult);
			uploader.load(deleteObjectRequest);
		}
		
		protected function handleSessionServiceResult(event:Event):void {
			dispatchEvent(new Event(SESSION_DELETED, true));		
		}
		
		public function removeEvent(eventId:String):void {
			var eventService:HTTPService = new HTTPService();
			eventService = new HTTPService();
			eventService.method = URLRequestMethod.GET;
			eventService.addEventListener(ResultEvent.RESULT, handleEventServiceResult);
			eventService.url = endpoint + "/event/" + eventId + "?token="+token;
			eventService.send();
		}
		
		protected function handleEventServiceResult(event:ResultEvent):void {
			eventObject = com.adobe.serialization.json.JSON.decode(String(event.result));
			
			//delete all interactions
			for each (var interaction:Object in eventObject.interactions) {
				deleteObjectRequest = new URLRequest(endpoint + "/interaction/" +interaction._id+ "?token="+token);
				deleteObjectRequest.method = URLRequestMethod.DELETE;
				deleteObjectRequest.contentType = "application/json";
				uploader = new URLLoader();
				uploader.load(deleteObjectRequest);
			}
			
			//delete event
			deleteObjectRequest = new URLRequest(endpoint + "/event/" +eventObject._id+ "?token="+token);
			deleteObjectRequest.method = URLRequestMethod.DELETE;
			uploader = new URLLoader();
			uploader.load(deleteObjectRequest);
			
			dispatchEvent(new Event(EVENT_DELETED, true));
		}
		
		
	}
}