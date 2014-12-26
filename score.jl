#!/usr/bin/env julia

@assert length(ARGS) == 1 "Original course file required as the first argument to script"

participant_courses = Dict{Int64,Vector{Int64}}()
course_participants = Dict{Int64,Vector{Int64}}()
f = open(ARGS[1])
for (index, line) in enumerate(eachline(f))
    if index == 1
        info(line)
        continue
    end

    parts = split(strip(line, '\n'), [' '])
    participant = int64(parts[1])
    courses = int64(parts[3:end])
    @assert length(courses) == uint16(parts[2])

    for course in courses
        if ! haskey(course_participants, course) course_participants[course] = [] end
        push!(course_participants[course], participant)

        if ! haskey(participant_courses, participant) participant_courses[participant] = [] end
        push!(participant_courses[participant], course)
    end
end
close(f)

participant_count = length(keys(course_participants))
info("Total participants: $participant_count")

course_count = length(keys(participant_courses))
info("Total courses: $course_count")


slots = Dict{Int64,Int64}()
for line in eachline(STDIN)
    parts = split(strip(line, '\n'), [' '])
    slots[int64(parts[1])] = int64(parts[2])
end

# @assert length(keys(slots)) == course_count "No slots for all courses"
if length(keys(slots)) != course_count
    slot_count = length(keys(slots))
    warn("No slots for all courses: length(keys(slots)): $slot_count != $course_count")
end

score = uint32(0)
not_on_slots = uint32(0)
for (participant, courses) in participant_courses
    slots_used = IntSet()
    for course in courses
        if ! haskey(slots, course)
            not_on_slots = not_on_slots + 1
            continue
        end

        course_slot = slots[course]
        if ! in(slots_used, course_slot)
            score = score + 1
            push!(slots_used, course_slot)
        end
    end
end

if not_on_slots > 0
    warn("$not_on_slots courses not designated to any slot")
end

println(score)
