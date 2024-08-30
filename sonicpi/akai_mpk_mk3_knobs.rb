# Experiments with AKAI MPK Mini MK3 midi controller
# and sonic pi.

# Store knob values (K1 == CH1/70, K8 == CH1/77)
KNOB_1 = 70
$midi = {}
live_loop :store_midi_control do
  use_real_time
  key,value = sync "/midi*/control_change"
  set "midi_cc_{key}".to_sym, value
  # But global variables are the best ;)
  $midi[key] = value
end

# returns min, default, max
def range_for_param param
  min_default_max = {
    amp: [0,1,10]
  }
  
  min_default_max[param]
end

# Defining them beforehand via metaprogramming would be
# more efficient, but lets try the whole approach first
# on something like "amp_from_knob1" return { amp: <value> }
# where value is the value stored from midi knob1 on the AKAI MPK MK3
# where the value is scaled according to above method ...
def method_missing m, *args, &block
  key, _, knob_id = m.to_s.split("_")

  if !(key && knob_id)
    super
  else
    #puts $midi
    mdm = range_for_param(key.to_sym)
    value = $midi[70 + knob_id[/\d+/].to_i - 1] # value from knob, scaled according to key, if found
    value = if mdm
      value ? (mdm[0] + (mdm[2] - mdm[0]) * value / 127.0) : mdm[1]
    end
    {
      key.to_sym => value
    }
  end
end

