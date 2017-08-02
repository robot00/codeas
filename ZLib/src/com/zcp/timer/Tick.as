package com.zcp.timer
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * EnterFrame统一触发
	 * @author zcp
	 * 
	 */	
	public class Tick
	{
		//enterFrame触发
		private static const _sp:Sprite = new Sprite();
		//回调字典
		private static var _funMap:Dictionary = new Dictionary();
		//回调函数数量
		private static var _funCount:int;
		//是否正在运行中
		private static var _running:Boolean = true;
		//是否正在睡眠模式中
		private static var _isSleep:Boolean = false;
		
		//执行触发时间间隔(用于判断是否处于睡眠模式)
		private static const TM_GAP:uint = 100;
		
		//上一次触发的时间
		private static var _preTime:Number = 0;
		//当前次触发的时间
		private static var _nowTime:Number = 0;
		//两次触发的时间差
		private static var _dTime:Number = 0;
		
		
		/**
		 * 是否正在睡眠模式中
		 * @return 
		 * 
		 */		
		public static function get isSleepMode():Boolean
		{
			return _isSleep;
		}
		
		/**
		 * 是否正在运行中
		 * @return 
		 * 
		 */		
		public static function get running():Boolean
		{
			return _running;
		}
		
		/**
		 * 开始(默认为开始状态)
		 * 
		 */		
		public static function start():void
		{
			if (!_running)
			{
				if(_funCount>0)
				{
					_sp.addEventListener(Event.ENTER_FRAME,onTick);
				}
				
				_running = true;
			}
		}
		
		/**
		 * 停止 
		 * 
		 */
		public static function stop():void
		{
			if (_running)
			{
				if(_funCount>0)
				{
					_sp.removeEventListener(Event.ENTER_FRAME,onTick);
					
					_preTime = 0;
					_nowTime = 0;
					_dTime = 0;
				}
				
				_running = false;
			}
		}
	
		/**
		 * 添加一个EnterFrame监听回调
		 * @param fun
		 * 
		 */		
		public static function addCallback(fun:Function):void
		{
			if(fun in _funMap)
			{
				return;
			}
			
			_funMap[fun] = true;
			_funCount++;
			
			if(_running)
			{
				if(_funCount==1)
				{
					_sp.addEventListener(Event.ENTER_FRAME,onTick);
				}
			}
		}
		/**
		 * 移除一个EnterFrame监听回调
		 * @param fun
		 * 
		 */		
		public static function removeCallback(fun:Function):void
		{
			if (fun in _funMap)
			{
				delete _funMap[fun];
				_funCount--;
				
				if(_running)
				{
					if(_funCount==0)
					{
						_sp.removeEventListener(Event.ENTER_FRAME,onTick);
						
						_preTime = 0;
						_nowTime = 0;
						_dTime = 0;
					}
				}
			}
		}
		/**
		 * 移除所有回调
		 * 
		 */		
		public static function removeAllCallbacks():void
		{
			if(_funCount==0)return;
			
			_funMap = new Dictionary();
			_funCount = 0;
			
			_sp.removeEventListener(Event.ENTER_FRAME,onTick);
			
			_preTime = 0;
			_nowTime = 0;
			_dTime = 0;
		}
		/**
		 * 是否存在某个回调 
		 * @param fun
		 * @return 
		 * 
		 */		
		public static function hasCallback(fun:Function):Boolean
		{
			return (fun in _funMap);
		}
		//onTick
		private static function onTick(e:Event):void
		{
			_nowTime = getTimer();
			
			if(_preTime>0)
			{
				_dTime = _nowTime - _preTime;
				_isSleep = (_dTime > TM_GAP);
				for (var fun:* in _funMap)
				{
//					fun(_dTime);
					fun();
//					if(getTimer() - _nowTime > 20)//统一回调处理,让帧负载均衡（不能如此控制如果负载过重， 那么会有后面的函数始终无法得到执行。）
//					{
//						break;
//					}
				}
			}
			
			_preTime = _nowTime;
		}
	}
}