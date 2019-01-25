#!/usr/bin/python


# - pyObjC (as such, recommended to be used with native OS X python install)


#import relevant libraries/frameworks
import objc, ctypes.util, os.path, collections
from Foundation import NSOrderedSet

#put SSIDs into array
PreferredSSIDs = ["SSID1", "SSID2", "SSID3"]

def load_objc_framework(framework_name):
    # Utility function that loads a Framework bundle and creates a namedtuple where the attributes are the loaded classes from the Framework bundle
    loaded_classes = dict()
    framework_bundle = objc.loadBundle(framework_name, bundle_path=os.path.dirname(ctypes.util.find_library(framework_name)), module_globals=loaded_classes)
    return collections.namedtuple('AttributedFramework', loaded_classes.keys())(**loaded_classes)

#load the CoreWLAN.framework
CoreWLAN = load_objc_framework('CoreWLAN')

#load all available wifi interfaces
interfaces = dict()
for i in CoreWLAN.CWInterface.interfaceNames():
    interfaces[i] = CoreWLAN.CWInterface.interfaceWithName_(i)

#repeat the configuration with every wifi interface
for i in interfaces.keys():
    #grab a mutable copy of this interface's configuration
    configuration_copy = CoreWLAN.CWMutableConfiguration.alloc().initWithConfiguration_(interfaces[i].configuration())
    #find all the preferred/remembered network profiles
    profiles = list(configuration_copy.networkProfiles())
    #grab all the SSIDs, in order
    SSIDs = [x.ssid() for x in profiles]
    #loop through PreferredSSIDs list in reverse order sorting each entry to the front of profiles array so it
    #ends up sorted with PreferredSSIDs as the first items.
    #order is preserved for other SSIDs, example where PreferredSSIDs is [ssid3, ssid4]:
    #original: [ssid1, ssid2, ssid3, ssid4]
    #new order: [ssid3, ssid4, ssid1, ssid2]
    for aSSID in reversed(PreferredSSIDs):
        profiles.sort(key=lambda x: x.ssid() == aSSID, reverse=True)
    #now we have to update the mutable configuration
    #first convert it back to a NSOrderedSet
    profile_set = NSOrderedSet.orderedSetWithArray_(profiles)
    #then set/overwrite the configuration copy's networkProfiles
    configuration_copy.setNetworkProfiles_(profile_set)
    #then update the network interface configuration
    result = interfaces[i].commitConfiguration_authorization_error_(configuration_copy, None, None)