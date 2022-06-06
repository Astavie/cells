package server

import "../vendor/xcb"

import "core:fmt"
import "core:sync"

Server :: struct {
    conn : ^xcb.Connection,
    screen : ^xcb.Screen,

    // Animation info

    animation_mutex : sync.Recursive_Mutex,
    animations : map[xcb.Window]Animation,
    movements : map[xcb.Window]Movement,

    // ATOMS

    _NET_WM_NAME : xcb.Atom,
}

// Connect to the X server
connect :: proc() -> (^Server, bool) {
    using s := new(Server)
    animations = make(map[xcb.Window]Animation)

    screen_index : i32 = ---
    conn = xcb.connect(nil, &screen_index)

    if conn == nil || xcb.connection_has_error(conn) != 0 {
        xcb.disconnect(conn)
        fmt.print("Could not connect to the X server\n")
        return nil, false
    }

    screen = xcb.setup_roots_iterator(xcb.get_setup(conn)).data

    return s, true
}

// Disconnect from the X server
disconnect :: proc(using s : ^Server) {
    xcb.disconnect(conn)
    delete(animations)
    free(s)
}
