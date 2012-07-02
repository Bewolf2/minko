package aerys.minko.type.data
{
	import aerys.minko.type.Signal;
	import aerys.minko.type.enum.DataProviderUsage;
	
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class DataProvider extends Proxy implements IDataProvider
	{
		private var _usage				: uint			= 1;
		private var _name				: String		= null;
		private var _descriptor			: Object		= {};
		
		private var _changed			: Signal		= new Signal('DataProvider.changed');
		private var _propertyChanged	: Signal		= new Signal('DataProvider.propertyChanged');
		
		private var _nameToProperty		: Object		= {};
		private var _propertyToNames	: Dictionary	= new Dictionary();  // dic[Vector.<String>[]]
		
		public function get usage() : uint
		{
			return _usage;
		}
		
		public function get dataDescriptor() : Object
		{
			return _descriptor;
		}
		
		public function get changed() : Signal
		{
			return _changed;
		}
		
		public function get propertyChanged() : Signal
		{
			return _propertyChanged;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name(v : String) : void
		{
			_name = v;
		}
		
		public function DataProvider(properties	: Object	= null, 
									 name		: String	= null,
									 usage		: uint		= 1)
		{
			_name	= name;
			_usage	= usage;
			
			initialize(properties);
		}
		
		private function initialize(properties : Object) : void
		{
			if (properties)
				for (var propertyName : String in properties)
					setProperty(propertyName, properties[propertyName]);
		}
		
		override flash_proxy function getProperty(name : *) : *
		{
			return getProperty(String(name));
		}
		
		override flash_proxy function setProperty(name : *, value : *) : void
		{
			setProperty(String(name), value);
		}
		
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			removeProperty(String(name));
			
			return true;
		}
		
		public function getProperty(name : String) : *
		{
			return _nameToProperty[name];
		}
		
		public function setProperty(name : String, newValue : Object) : DataProvider
		{
			var oldValue : Object	= _nameToProperty[name];
			var oldMonitoredValue	: IMonitoredData	= oldValue as IMonitoredData;
			var newMonitoredValue	: IMonitoredData	= newValue as IMonitoredData;
			var oldPropertyNames	: Vector.<String>	= _propertyToNames[oldMonitoredValue];
			var newPropertyNames	: Vector.<String>	= _propertyToNames[newMonitoredValue];
			
			if (oldMonitoredValue != null)
			{
				if (oldPropertyNames.length == 1)
				{
					oldMonitoredValue.changed.remove(propertyChangedHandler);
					delete _propertyToNames[oldMonitoredValue];
				}
				else
					oldPropertyNames.splice(oldPropertyNames.indexOf(name), 1);
			}
			
			if (newMonitoredValue != null)
			{
				if (newPropertyNames == null)
				{
					newPropertyNames = _propertyToNames[newMonitoredValue] = new <String>[name];
					newMonitoredValue.changed.add(propertyChangedHandler);
				}
				else
					newPropertyNames.push(name);
			}
			
			_descriptor[name]		= name;
			_nameToProperty[name]	= newValue;
			
			if (oldValue === null)
				_changed.execute(this, 'dataDescriptor');
			else
				_changed.execute(this, name);
			
			return this;
		}
		
		public function setProperties(properties : Object) : DataProvider
		{
			for (var propertyName : String in properties)
				setProperty(propertyName, properties[propertyName]);
				
			return this;
		}
		
		public function removeProperty(name : String) : DataProvider
		{
			var oldMonitoredValue	: IMonitoredData	= _nameToProperty[name] as IMonitoredData;
			var oldPropertyNames	: Vector.<String>	= _propertyToNames[oldMonitoredValue];
			
			delete _descriptor[name];
			delete _nameToProperty[name];
			
			if (oldMonitoredValue != null)
			{
				if (oldPropertyNames.length == 1)
				{
					oldMonitoredValue.changed.remove(propertyChangedHandler);
					delete _propertyToNames[oldMonitoredValue];
				}
				else
					oldPropertyNames.splice(oldPropertyNames.indexOf(name), 1);
			}
			
			_changed.execute(this, 'dataDescriptor');
			
			return this;
		}
		
		public function removeAllProperties() : DataProvider
		{
			for (var propertyName : String in _nameToProperty)
				removeProperty(propertyName);
			
			return this;
		}
		
		public function propertyExists(name : String) : Boolean
		{
			return _descriptor.hasOwnProperty(name);
		}
		
		public function invalidate() : DataProvider
		{
			_changed.execute(this, null);
			
			return this;
		}
		
		public function clone() : IDataProvider
		{
			switch (_usage)
			{
				case DataProviderUsage.EXCLUSIVE:
				case DataProviderUsage.SHARED:
					return new DataProvider(_nameToProperty, _name + '_cloned', _usage);
				
				case DataProviderUsage.MANAGED:
					throw new Error('This dataprovider is managed, and must not be cloned');
					
				default:
					throw new Error('Unkown usage value');
			}
		}
		
		private function propertyChangedHandler(source : IMonitoredData, key : String) : void
		{
			var names		: Vector.<String>	= _propertyToNames[source];
			var numNames	: uint				= names.length;
			
			for (var nameId : uint = 0; nameId < numNames; ++nameId)
				_propertyChanged.execute(this, names[nameId]);
		}
	}
}
