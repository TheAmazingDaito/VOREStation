// I know it's a ball of goop, but it's basically a device okay.
/obj/item/device/shelterball
	name = "surfluid sphere"
	desc = "A glass ball full of inky black fluid. It twitches and shifts as if it were alive. Etched on the outside is some sort of license to use and operate this device on behalf of NanoTrasen."
	icon = 'icons/obj/device_alt.dmi'
	icon_state = "powersink0"
	origin_tech = list(TECH_MAGNET = 5, TECH_BLUESPACE = 5, TECH_MATERIAL = 5, TECH_ENGINEERING = 5, TECH_DATA = 5)

	var/size = 3 //Interior space, length per inside wall (3 = 3x3 interior, 5x5 footprint). Odd number pls.
	var/turf/target_turf
	var/list/turfs_to_goo
	var/goo_helper

	var/goo_type = /obj/item/surfluid_goop
	var/floor_type = /turf/simulated/shuttle/floor/voidcraft
	var/wall_type = /turf/simulated/shuttle/wall/voidcraft/red
	var/door_type = /obj/machinery/door/airlock/voidcraft

/obj/item/device/shelterball/Destroy()
	qdel_null(goo_helper)
	target_turf = null
	LAZYCLEARLIST(turfs_to_goo)
	return ..()

// Throwing it deploys it.
/obj/item/device/shelterball/throw_impact(turf/T, speed)
	. = ..()

	if(CheckBuild(T))
		visible_message("<b>[src]</b> humms softly.")
		BeginBuild(T)
	else
		visible_message("<b>[src]</b> vibrates angrily before settling down.")

/obj/item/device/shelterball/proc/CheckBuild(turf/T)
	var/from_edges = size+2

	// Can't build on this z-level
	if(T.z in using_map.admin_levels)
		return FALSE
	
	// Too close to an edge
	if(T.x < from_edges || T.y < from_edges || (world.maxx - T.x) < from_edges || (world.maxy - T.y) < from_edges)
		return FALSE

	// No reason not to
	return TRUE

/obj/item/device/shelterball/proc/BeginBuild(turf/T)
	target_turf = T
	goo_helper = new goo_type

	PlaceFoundation()
	sleep(10 SECONDS)
	PlaceFlooring()
	sleep(10 SECONDS)
	PlaceWalls()
	sleep(10 SECONDS)
	PlaceDoor()

/obj/item/device/shelterball/proc/PlaceFoundation()
	turfs_to_goo = list()
	//This list should be: (size+2)^2 in length
	//The first size^2 entries should be floor.
	//The final len-size^2 should be walls.
	spiral_range_turfs(Floor((size+2)/2), src, FALSE, turfs_to_goo, TRUE)
	forceMove(null)
	for(var/tf in turfs_to_goo)
		sleep(5)
		var/turf/T = tf
		T.vis_contents += goo_helper

/obj/item/device/shelterball/proc/PlaceFlooring()
	var/inside_area = size**2
	for(var/i in 1 to inside_area)
		sleep(5)
		var/turf/T = turfs_to_goo[i]
		for(var/atom/movable/AM in T)
			qdel(AM)
		T.ChangeTurf(floor_type)
		T.vis_contents -= goo_helper

/obj/item/device/shelterball/proc/PlaceWalls()
	var/inside_area = size**2
	var/outside_edge = turfs_to_goo.len - inside_area
	var/outside_edge_start = turfs_to_goo.len - (outside_edge-1)
	var/length = turfs_to_goo.len //I don't trust for() to not check this every time

	for(var/i in outside_edge_start to length)
		sleep(5)
		var/turf/T = turfs_to_goo[i]
		for(var/atom/movable/AM in T)
			qdel(AM)
		T.ChangeTurf(wall_type)
		T.vis_contents -= goo_helper

	//Shuttle walls get prettified
	for(var/turf/simulated/shuttle/wall/W in turfs_to_goo)
		W.auto_join()
		W.update_icon()
		if(W.takes_underlays)
			W.underlay_update()

/obj/item/device/shelterball/proc/PlaceDoor()
	var/door_x = target_turf.x
	var/door_y = target_turf.y
	var/side = pick(cardinal)
	switch(side)
		if(NORTH)
			door_y += Floor((size+2)/2)
		if(SOUTH)
			door_y -= Floor((size+2)/2)
		if(EAST)
			door_x += Floor((size+2)/2)
		if(WEST)
			door_x -= Floor((size+2)/2)
	var/turf/T = locate(door_x,door_y,target_turf.z)
	T.ChangeTurf(floor_type)
	var/obj/door = new door_type(T)
	door.dir = side
	qdel(src)

/obj/item/surfluid_goop
	name = "working surface"
	icon = 'icons/effects/cameravis.dmi'
	icon_state = "black"
	plane = TURF_PLANE
