package com.britzpetermann.phadpad.core
{
	import flash.utils.ByteArray;

	public interface RemoteCommand
	{
		function execute(inputId : int, stream : ByteArray) : void;
	}
}
