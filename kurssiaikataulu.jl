#!/usb/bin/env julia

import Base.Collections
import Base.Order
import Base.hash

immutable Course
    name::Int
    participants::IntSet
    size::Int
end

immutable Student
    name::Int
    course_names::Vector{Int}
end

hash(c::Course) = hash(c.name) + hash(c.participants) + hash(c.size)
# isequal(a::Course, b::Course) =
#     a.name == b.name && a.participants == b.participants && a.size == b.size

function isequal(a::Course, b::Course)
    function sets_equal(c, d)
        length(union(c, d)) == length(c) == length(d)
    end

    a.name == b.name && sets_equal(a.participants, b.participants) && a.size == b.size
end

==(a::Course, b::Course) = isequal(a, b)

function test()
    foo = Course(1449, IntSet([3430,23568,60771,91142]), 4)
    bar = Course(1449, IntSet([3430,23568,60771,91142]), 4)
    @assert isequal(foo, bar)
    @assert foo == bar
    @assert hash(foo) == hash(bar)
    baz = convert(Course, bar)
    @assert isequal(bar, baz)
end
test()

function read_students(stream)
    result = Dict{Int, Student}()

    for (index, line) in enumerate(eachline(stream))
        if index == 1
            info(line)
            continue
        end

        parts = split(strip(line, ' '))
        student = parseint(parts[1])
        course_count = parseint(parts[2])

        courses = Int[]
        map(x->push!(courses, parseint(x)), parts[3:end])
        result[student] = Student(student, courses)
    end

    result
end

function to_courses(students)
    course_applicants = Dict{Int, Vector{Int}}()
    for (student_name, student) in students
        for course_name in student.course_names
            if ! haskey(course_applicants, course_name) course_applicants[course_name] = [] end
            push!(course_applicants[course_name], student_name)
        end
    end

    result = Dict{Int, Course}()
    for (course_name, student_names) in course_applicants
        students = IntSet()
        for student_name in student_names
            push!(students, student_name)
        end
        result[course_name] = Course(course_name, students, length(student_names))
    end

    result
end

function pop_order(courses)
    pq = Collections.PriorityQueue{Course, Int}(Order.Reverse)
    for course in courses
        Collections.enqueue!(pq, course, course.size)
    end

    result = Course[]
    while length(pq) > 0
        push!(result, Collections.dequeue!(pq))
    end
    result
end


function quick_copy(s::IntSet)
    result = IntSet()
    result.bits = copy(s.bits)
    result.limit = copy(s.limit)
    result.fill1s = s.fill1s
    result
end

function overlap_score(other_courses::Vector{Course}, course::Course)
    if length(other_courses) == 0
        course.size
    else
        result::Int = 0
        for other in other_courses
            # a::IntSet = copy(course.participants)
            a::IntSet = quick_copy(course.participants)
            b::IntSet = other.participants
            intersection = intersect!(a, b)
            overlap = length(intersection)
            score = other.size - overlap
            result += score
        end
        result
    end
end

function best_course_for_spot(course_names_left, courses_in_popularity_order, other_courses)
    best_candidate = nothing
    best_score = nothing
    for course in courses_in_popularity_order
        if !in(course.name, course_names_left) continue end

        score = overlap_score(other_courses, course)
        if best_score == nothing || score > best_score
            best_score = score
            best_candidate = course
        end
    end

    @assert best_candidate != nothing
    best_candidate
end

function main()
    students = read_students(STDIN)
    info("Input read")
    courses = to_courses(students)
    pop_ordered_courses = pop_order(values(courses))
    info("Preparations done")

    course_names_left = IntSet(keys(courses))
    courses_on_spot = Dict{Int, Vector{Course}}()
    current_spot = 1
    # loops = 0
    while length(course_names_left) > 0
        if length(course_names_left) % 100 == 0
            info("$(length(course_names_left))/$(length(courses))")
        end

        if ! haskey(courses_on_spot, current_spot) courses_on_spot[current_spot] = [] end
        other_courses = courses_on_spot[current_spot]

        best_course = best_course_for_spot(course_names_left, pop_ordered_courses, other_courses)

        push!(courses_on_spot[current_spot], best_course)
        delete!(course_names_left, best_course.name)
        write(STDOUT, "$(best_course.name) $current_spot\n")
        flush(STDOUT)

        current_spot += 1
        if current_spot > 25
            current_spot = 1
            # loops += 1

            # if loops == 10
            #     break
            # end
        end
    end
end

# import Base.Profile
# @profile main()
# # Profile.print(cols=120)
# Profile.print(format=:flat, cols=120)


main()
