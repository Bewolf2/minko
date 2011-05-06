package aerys.minko.type.vertex.format
{
	public class VertexComponent
	{
		public static const XYZ		: VertexComponent 	= new VertexComponent(["x", "y", "z"], NativeFormat.FLOAT_3);
		public static const UV		: VertexComponent 	= new VertexComponent(["u", "v"], NativeFormat.FLOAT_2);
		public static const RGB		: VertexComponent 	= new VertexComponent(["r", "g", "b"], NativeFormat.FLOAT_3);
		public static const NORMAL	: VertexComponent 	= new VertexComponent(["nx", "ny", "nz"], NativeFormat.FLOAT_3);
		public static const ST		: VertexComponent 	= new VertexComponent(["s", "t"], NativeFormat.FLOAT_2);
		public static const BONE	: VertexComponent	= new VertexComponent(["id", "weight"], NativeFormat.FLOAT_2);
		
		private var _nativeFormat	: int;
		private var _fields			: Array;
		private var _offsets		: Object;
		private var _implodedFields	: String;	// used to avoid array comparison
		
		public function get dwords()				: int 		{ return NativeFormat.NB_DWORDS[_nativeFormat]; }
		public function get offsets()				: Object 	{ return _offsets; }
		public function get fields()				: Array 	{ return _fields; } 
		public function get nativeFormat()			: int		{ return _nativeFormat; }
		public function get nativeFormatString()	: String 	{ return NativeFormat.STRINGS[_nativeFormat]; }
		public function get implodedFields()		: String 	{ return _implodedFields; }
		
		public function VertexComponent(fields : Array, nativeFormat:int) 
		{
			_offsets		= new Object();
			_nativeFormat	= nativeFormat;
			_fields			= fields;
			_implodedFields	= fields.join(", ");
			
			for (var offset : int = 0; offset < fields.length; ++offset)
				_offsets[fields[offset]] = offset;
		}
		
		public function isSameAs(otherComponent : VertexComponent) : Boolean
		{
			return _nativeFormat == otherComponent._nativeFormat && _implodedFields == otherComponent._implodedFields;
		}
		
		public function hasField(fieldName : String) : Boolean
		{
			return _offsets[fieldName] !== undefined;
		}
		
		public function toString() : String
		{
			return _implodedFields;
		}
		
	}
}