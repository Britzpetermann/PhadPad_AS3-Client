package com.britzpetermann.phadpad.command
{

	[Event(name="begin", type="com.britzpetermann.phadpad.command.TouchEvent")]
	public class TouchBeginCommand extends TouchCommand
	{
		public function TouchBeginCommand()
		{
			eventType = TouchEvent.BEGIN;
		}
	}
}
