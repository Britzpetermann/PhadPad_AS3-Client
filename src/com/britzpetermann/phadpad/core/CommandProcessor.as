package com.britzpetermann.phadpad.core
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class CommandProcessor
	{
		private var commandIdToCommand : Dictionary = new Dictionary();

		public function addCommand(commandId : int, command : RemoteCommand) : void
		{
			commandIdToCommand[commandId] = command;
		}

		public function process(inputId : int, commandId : int, stream : ByteArray) : void
		{
			var command : RemoteCommand = commandIdToCommand[commandId];
			if (command == null)
			{
				trace("RemoteInput: unknown command with id " + commandId + " and length " + stream.length);
				for (var i : int = 0; i < stream.length; i++)
				{
					trace("\t", stream.readByte());
				}
			}
			else
			{
				command.execute(inputId, stream);
			}
		}
	}
}
