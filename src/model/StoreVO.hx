package model;

class StoreVO extends SearchVO {

	public var _id : Int;

	public function new(?data:SearchVO):Void
	{
		super();
		if(data != null)
		{
			this.name = data.name;
			this.id = data.id;
		}
	}
	
}