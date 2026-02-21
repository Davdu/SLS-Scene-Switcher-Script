import obspython as S
import requests as R
import threading
import time

settings_cache = None
switchable_scenes = []
is_shutting_down = False

def run_query_thread():
    global settings_cache, is_shutting_down
    
    if is_shutting_down or settings_cache is None:
        return
    
    active = S.obs_data_get_bool(settings_cache, "activateSwitcher")
    if not active:
        return

    statsURL = S.obs_data_get_string(settings_cache, "statsURL")
    publisher = S.obs_data_get_string(settings_cache, "publisher")

    if statsURL != "" and publisher != "":
        thread = threading.Thread(target=QueryStats, args=[statsURL, publisher], daemon=True)
        thread.start()

def QueryStats(StatsURL, publisher):
    global is_shutting_down, settings_cache
    
    if is_shutting_down or settings_cache is None:
        return
    
    try:
        # Check current scene for being among switchables.
        currentScene = get_current_scene()

        if not currentScene or currentScene not in switchable_scenes:
            return

        response = R.get(url=StatsURL, timeout=5)
        
        if is_shutting_down or settings_cache is None:
            return
            
        if response.status_code == 200:
            data = response.json()
            
            if is_shutting_down or settings_cache is None:
                return
            
            bitrate = int(data["publishers"][publisher]["bitrate"])
            
            if bitrate < S.obs_data_get_int(settings_cache, "bitrateThreshold"):
                switch_scene(S.obs_data_get_string(settings_cache, "lowScene"))
            else:
                switch_scene(S.obs_data_get_string(settings_cache, "liveScene"))

    except R.exceptions.RequestException:
        pass
    except ValueError:
        pass
    except KeyError:
        if not is_shutting_down and settings_cache is not None:
            switch_scene(S.obs_data_get_string(settings_cache, "offlineScene"))

def switch_scene(scene):
    global is_shutting_down
    
    if is_shutting_down or not scene:
        return
    
    current_scene_source = None
    scenes_list = None
    
    try:
        # Check current scene again.
        currentScene = get_current_scene()
        
        if not currentScene or currentScene not in switchable_scenes or currentScene == scene:
            return
        
        # Get scenes list
        scenes_list = S.obs_frontend_get_scenes()
        if not scenes_list:
            return
        
        # Find and switch to target scene
        for s in scenes_list:
            if not s:
                continue
            
            name = S.obs_source_get_name(s)
            
            if name == scene:
                S.obs_frontend_set_current_scene(s)
                break
        
        # CRITICAL: Release all scene references
        for s in scenes_list:
            if s:
                S.obs_source_release(s)
        scenes_list = None
        
    except:
        pass
    finally:
        # Ensure references are released even on error
        if current_scene_source is not None:
            try:
                S.obs_source_release(current_scene_source)
            except:
                pass
        
        if scenes_list is not None:
            try:
                for s in scenes_list:
                    if s:
                        S.obs_source_release(s)
            except:
                pass

def get_current_scene():
    # Get current scene
        current_scene_source = S.obs_frontend_get_current_scene()
        if not current_scene_source:
            return None
        
        currentScene = S.obs_source_get_name(current_scene_source)
        
        # CRITICAL: Release the source reference immediately after getting the name
        S.obs_source_release(current_scene_source)
        current_scene_source = None
        
        return currentScene

def script_load(settings):
    global settings_cache, switchable_scenes, is_shutting_down
    is_shutting_down = False
    settings_cache = settings
    switchable_scenes = [
        S.obs_data_get_string(settings, "liveScene"),
        S.obs_data_get_string(settings, "lowScene"),
        S.obs_data_get_string(settings, "offlineScene")
    ]

def script_unload():
    global is_shutting_down, settings_cache
    
    is_shutting_down = True
    
    try:
        S.timer_remove(run_query_thread)
    except:
        pass
    
    # Give threads time to see shutdown flag
    time.sleep(0.2)
    
    settings_cache = None

def script_update(settings):
    global settings_cache, switchable_scenes, is_shutting_down
    
    if is_shutting_down:
        return
    
    settings_cache = settings
    switchable_scenes = [
        S.obs_data_get_string(settings, "liveScene"),
        S.obs_data_get_string(settings, "lowScene"),
        S.obs_data_get_string(settings, "offlineScene")
    ]
    
    try:
        S.timer_remove(run_query_thread)
    except:
        pass
    
    interval = S.obs_data_get_int(settings, "queryInterval")
    if interval > 0 and not is_shutting_down:
        S.timer_add(run_query_thread, interval * 1000)

def script_description():
    return "Automatically switches scenes based on the state of the configured SLS stream"

def script_defaults(settings):
    S.obs_data_set_default_bool(settings, "activateSwitcher", False)
    S.obs_data_set_default_string(settings, "statsURL", "http://<example>.com/stats")
    S.obs_data_set_default_string(settings, "publisher", "live/stream/")
    S.obs_data_set_default_int(settings, "bitrateThreshold", 300)
    S.obs_data_set_default_int(settings, "queryInterval", 5)

def script_properties():
    props = S.obs_properties_create()

    activeProp = S.obs_properties_add_bool(
        props,
        "activateSwitcher",
        "Activate Switcher"
    )

    liveScene = S.obs_properties_add_list(
        props,
        "liveScene",
        "Live Scene",
        S.OBS_COMBO_TYPE_EDITABLE,
        S.OBS_COMBO_FORMAT_STRING,
    )
    
    lowScene = S.obs_properties_add_list(
        props,
        "lowScene",
        "Low Scene",
        S.OBS_COMBO_TYPE_EDITABLE,
        S.OBS_COMBO_FORMAT_STRING,
    )
        
    offlineScene = S.obs_properties_add_list(
        props,
        "offlineScene",
        "Offline Scene",
        S.OBS_COMBO_TYPE_EDITABLE,
        S.OBS_COMBO_FORMAT_STRING,
    )

    # Get scenes and release them properly
    scenes_list = S.obs_frontend_get_scenes()
    if scenes_list:
        for scene in scenes_list:
            if scene:
                name = S.obs_source_get_name(scene)
                S.obs_property_list_add_string(liveScene, name, name)
                S.obs_property_list_add_string(lowScene, name, name)
                S.obs_property_list_add_string(offlineScene, name, name)
        
        # Release all scene references
        for scene in scenes_list:
            if scene:
                S.obs_source_release(scene)

    statURLProp = S.obs_properties_add_text(
        props,
        "statsURL",
        "Stats Page URL",
        S.OBS_TEXT_DEFAULT
    )

    publisherProp = S.obs_properties_add_text(
        props,
        "publisher",
        "Publisher",
        S.OBS_TEXT_DEFAULT
    )

    bitrateThreshold = S.obs_properties_add_int(
        props, 
        "bitrateThreshold", 
        "LOW Bitrate Threshold", 
        0, 
        99999, 
        1
    )

    queryInterval = S.obs_properties_add_int(
        props,
        "queryInterval",
        "Query Interval (Seconds)",
        1,
        60,
        1
    )
    return props
