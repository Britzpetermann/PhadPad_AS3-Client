package com.britzpetermann.phadpad.command
{

	[Event(name="move", type="com.britzpetermann.phadpad.command.TouchEvent")]
	public class TouchMoveCommand extends TouchCommand
	{
		public function TouchMoveCommand()
		{
			eventType = TouchEvent.MOVE;
		}
	}
}
