#!/usb/bin/env julia

import Base.Collections
import Base.Order
import Base.hash

immutable Course
    name::Int
    participants::Set{Int}
    size::Int
end

immutable Student
    name::Int
    course_names::Vector{Int}
end

hash(c::Course) = hash(c.name) + hash(c.participants) + hash(c.size)

function isequal(a::Course, b::Course)
    function sets_equal(c, d)
        issubset(c, d) && issubset(d, c)
    end

    a.name == b.name && sets_equal(a.participants, b.participants) && a.size == b.size
end

==(a::Course, b::Course) = isequal(a, b)

function test()
    foo = Course(1449, Set([3430,23568,60771,91142]), 4)
    bar = Course(1449, Set([3430,23568,60771,91142]), 4)
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
        students = Set{Int}()
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

function overlap_score(other_courses::Vector{Course}, course::Course)
    if length(other_courses) == 0
        course.size
    else
        result::Int = 0
        for other in other_courses
            intersection = intersect(course.participants, other.participants)
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
    last_speed_printout = time()
    while length(course_names_left) > 0
        if length(course_names_left) % 100 == 0
            now = time()
            secs = now - last_speed_printout
            info("$(length(course_names_left))/$(length(courses)) [$(100 / secs) courses/s]")
            last_speed_printout = now
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
        end
    end
end

main()
