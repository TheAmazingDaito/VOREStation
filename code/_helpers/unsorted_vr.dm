/*
	get_holder_at_turf_level(): Similar to get_turf(), will return the "highest up" holder of this atom, excluding the turf.
	Example: A fork inside a box inside a locker will return the locker. Essentially, get_just_before_turf().
*/ //Credit to /vg/
/proc/get_holder_at_turf_level(const/atom/movable/O)
	if(!istype(O)) //atom/movable does not include areas
		return
	var/atom/A
	for(A=O, A && !isturf(A.loc), A=A.loc);  // semicolon is for the empty statement
	return A

/proc/get_safe_ventcrawl_target(var/obj/machinery/atmospherics/unary/vent_pump/start_vent)
	if(!start_vent.network || !start_vent.network.normal_members.len)
		return
	var/list/vent_list = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in start_vent.network.normal_members)
		if(vent == start_vent)
			continue
		if(vent.welded)
			continue
		if(istype(get_area(vent), /area/crew_quarters/sleep)) //No going to dorms
			continue
		vent_list += vent
	if(!vent_list.len)
		return
	return pick(vent_list)

/proc/split_into_3(var/total)
	if(!total || !isnum(total))
		return

	var/part1 = rand(0,total)
	var/part2 = rand(0,total)
	var/part3 = total-(part1+part2)

	if(part3<0)
		part1 = total-part1
		part2 = total-part2
		part3 = -part3

	return list(part1, part2, part3)

//Sender is optional
/proc/admin_chat_message(var/message = "Debug Message", var/color = "#FFFFFF", var/sender)
	if (!config.chat_webhook_url || !message)
		return
	spawn(0)
		var/query_string = "type=adminalert"
		query_string += "&key=[url_encode(config.chat_webhook_key)]"
		query_string += "&msg=[url_encode(message)]"
		query_string += "&color=[url_encode(color)]"
		if(sender)
			query_string += "&from=[url_encode(sender)]"
		world.Export("[config.chat_webhook_url]?[query_string]")

//similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)
/proc/spiral_range_turfs(dist=0, center=usr, orange=0, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return L
