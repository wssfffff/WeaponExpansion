package
{
	import flash.display.MovieClip;
	
	public class ToggleMenuButtonGraphic extends MovieClip
	{
		public function ToggleMenuButtonGraphic()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		internal function frame1() : *
		{
			stop();
		}
	}
}