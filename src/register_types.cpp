#include "register_types.hpp"

#include "gdmozok.hpp"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include <memory>

using namespace godot;

void initialize_mozok_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<LibMozokServer>();
}

void uninitialize_mozok_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT mozok_library_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address, 
        const GDExtensionClassLibraryPtr p_library, 
        GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(
            p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_mozok_module);
    init_obj.register_terminator(uninitialize_mozok_module);
    init_obj.set_minimum_library_initialization_level(
            MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
