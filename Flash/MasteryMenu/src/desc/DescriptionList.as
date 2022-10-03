package desc
{
	import flash.display.MovieClip;
	import LS_Classes.scrollList;
	import LS_Classes.horizontalList;
	import flash.external.ExternalInterface;
	
	public dynamic class DescriptionList extends scrollList
	{
		public var icon_index:int = 0;
		
		public function DescriptionList()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();
		}

		public function clearIcons() : void
		{
			Registry.call("LLWEAPONEX_MasteryMenu_ClearIcons", icon_index);
			this.icon_index = 0;
		}

		public function addText(text:String, reposition:Boolean = true) : *
		{
			var entryContent:DescriptionText = new DescriptionText();
			entryContent.setText(text);
			entryContent.width = this.width - (this.SIDE_SPACING * 2);
			this.addElement(entryContent, reposition, false);
		}

		public function addIcon(bonusID:String, id:String, icon:String = "", iconType:int = 1, reposition:Boolean = true) : *
		{
			var entryContent:DescriptionIcon = new DescriptionIcon();
			entryContent.id = id;
			entryContent.bonusID = bonusID;
			entryContent.iconType = iconType;
			switch(icon)
			{
				case "LLWEAPONEX_UI_PassiveBonus":
					entryContent.icon = "LLWEAPONEX_UI_PassiveBonus";
					entryContent.createIcon_symbol();
					break;
				case "":
					entryContent.icon = "iggy_masteryMenu_unknown";
					entryContent.createIcon();
					break;
				default:
					//var iconIggyName:String = "masteryMenu_" + String(this.icon_index);
					var iconIggyName:String = "masteryMenu_" + String(icon);
					Registry.call("LLWEAPONEX_MasteryMenu_RegisterIcon", iconIggyName, icon, iconType);
					entryContent.icon = "iggy_" + iconIggyName;
					entryContent.createIcon();
					this.icon_index = this.icon_index + 1;
			}
			addElement(entryContent, reposition, false);
		}

		private function TryGetIconName(arr:Array, i:int) : String
		{
			try
			{
				if (arr.length > i)
				{
					return arr[i];
				}
				return "";
			}
			catch(e)
			{
				Registry.call("UIAssert","[MasteryMenu:TryGetIconName] Error occurred when trying to get an icon name from array.");
			}
			return "";
		}

		private function TryGetIconType(arr:Array, i:int) : int
		{
			try
			{
				if (arr.length > i)
				{
					return int(arr[i]);
				}
				return 1;
			}
			catch(e)
			{
				Registry.call("UIAssert","[MasteryMenu:TryGetIconType] Error occurred when trying to get an icon type from array.");
			}
			return 1;
		}

		public function addIconGroup(bonusID:String, ids:String, icons:String, types:String, reposition:Boolean = true, delimiter:String = ";") : *
		{
			var entryList:horizontalList = new horizontalList();
			entryList.m_MaxWidth = this.width - (this.SIDE_SPACING * 2);
			var iconIds:Array = ids.split(delimiter);
			var iconNames:Array = icons.split(delimiter);
			var iconTypes:Array = types.split(delimiter);

			//trace(iconIds, iconNames, iconTypes)

			var i:uint = 0;
			while (i < iconIds.length)
			{
				var iconId:String = iconIds[i];
				var iconName:String = TryGetIconName(iconNames, i);
				var iconType:int = TryGetIconType(iconTypes, i);
				if (iconName == null)
				{
					iconName = "";
				}
				if (iconType <= 0)
				{
					iconType = 1;
				}
				else if (iconType > 2)
				{
					iconType = 2;
				}
				//trace(iconId, iconName, iconType)
				var entryContent:DescriptionIcon = new DescriptionIcon();
				entryContent.iconType = iconType;
				entryContent.id = iconId;
				entryContent.bonusID = bonusID;
				switch(iconName)
				{
					case "LLWEAPONEX_UI_PassiveBonus":
						entryContent.icon = "LLWEAPONEX_UI_PassiveBonus";
						entryContent.createIcon_symbol();
						break;
					case "":
						if (iconType >= 2) {
							entryContent.icon = "iggy_LLWEAPONEX_MasteryMenu_UnknownSmall";
						} else {
							entryContent.icon = "iggy_LLWEAPONEX_MasteryMenu_Unknown";
						}
						entryContent.createIcon();
						break;
					default:
						var iconIggyName:String = "LLWEAPONEX_MasteryMenu_" + String(this.icon_index);
						Registry.call("LLWEAPONEX_MasteryMenu_RegisterIcon", iconIggyName, iconName, iconType);
						entryContent.icon = "iggy_" + iconIggyName;
						entryContent.createIcon();
						this.icon_index = this.icon_index + 1;
				}
				entryList.addElement(entryContent, false, false);
				i++;
			}

			entryList.positionElements();

			addElement(entryList, reposition, false);
		}
	}
}