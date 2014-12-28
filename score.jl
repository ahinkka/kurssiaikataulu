#!/usr/bin/env julia

@assert length(ARGS) == 1 "Original course file required as the first argument to script"

course_slots = Dict{Int,Int}()
for line in eachline(STDIN)
    parts = split(strip(line, '\n'), [' '])
    course = parseint(parts[1])
    slot = parseint(parts[2])
    course_slots[course] = slot
end
info("Slots read")

score = 0
slots_taken = Dict{Int,IntSet}()
f = open(ARGS[1])
for (index, line) in enumerate(eachline(f))
    if index == 1
        info(line)
        continue
    end

    parts = split(strip(line, '\n'), [' '])
    student = parseint(parts[1])
    courses = Set{Int}()
    map(x->push!(courses, parseint(x)), parts[3:end])
    @assert length(courses) == parseint(parts[2])

    if !haskey(slots_taken, student) slots_taken[student] = IntSet() end
    for course in courses
        course_slot = course_slots[course]
        if in(course_slot, slots_taken[student])
            continue
        else
            score += 1
            push!(slots_taken[student], course_slot)
        end
    end
end
close(f)

println(string(score))
