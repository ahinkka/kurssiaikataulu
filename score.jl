#!/usr/bin/env julia

@assert length(ARGS) == 1 "Original course file required as the first argument to script"

participant_courses = Dict{ASCIIString,Vector{ASCIIString}}()
course_participants = Dict{ASCIIString,Vector{ASCIIString}}()
f = open(ARGS[1])
for (index, line) in enumerate(eachline(f))
    if index == 1
        info(line)
        continue
    end

    parts = split(strip(line, '\n'), [' '])
    course = parts[1]
    participants = parts[3:end]
    @assert length(participants) == uint16(parts[2])

    for participant in participants
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


slots = Dict{ASCIIString,ASCIIString}()
for line in eachline(STDIN)
    parts = split(strip(line, '\n'), [' '])
    slots[parts[1]] = parts[2]
end

@assert length(keys(slots)) == course_count "No slots for all courses"

score = uint32(0)
# for (student, student_courses) in courses
#     slots_used = Set{ASCIIString}()
#     for course in student_courses
#         if ! haskey(slots, course)
#             warn("Course $course not in slots")
#             continue
#         end

#         course_slot = slots[course]
#         if ! in(slots_used, course_slot)
#             score = score + 1
#             push!(slots_used, course_slot)
#         end
#     end
# end

user_slot_used = Dict{ASCIIString,Set{ASCIIString}}() # user => set of slots used for user
for (course, participants) in course_participants
    # if ! haskey(slots, course)
    #     warn("Course $course not in slots")
    #     continue
    # end

    slot = slots[course]
    for participant in participants
        if ! haskey(user_slot_used, participant)
            user_slot_used[participant] = Set{ASCIIString}()
        end

        if in(user_slot_used[participant], slot)
            continue
        end

        score = score + 1
        push!(user_slot_used[participant], slot)
    end
end

println(score)
