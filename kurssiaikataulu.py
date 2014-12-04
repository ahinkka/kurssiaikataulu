from __future__ import print_function

import sys
import collections
import operator
import heapq

import bitsets

def debug(*args, **kwargs):
    kwargs['file'] = sys.stderr
    return print('#', *args, **kwargs)

# Basic data structures
students = {}
students_total = None
courses_total = None
students_per_course = None
all_courses = set()

# Read input from stdin, first line requires special handling
linenum = 0
for line in sys.stdin:
    if linenum == 0:
        students_total, courses_total, students_per_course = (int(part) for part in line.strip().split(' '))
        linenum += 1
    else:
        parts = line.strip().split(' ')
        student = parts[0]
        course_count = int(parts[1])
        courses = parts[2:]
        for course in courses:
            all_courses.add(course)

        students[student] = (course_count, courses)

all_courses = frozenset(all_courses)
Students = bitsets.bitset('Students', tuple(students.keys()))

# Print out sanity check statistics
debug(students_total, courses_total, students_per_course)
debug(len(students))

courses_sum = 0
for student in students.keys():
    course_count, _ = students[student]
    courses_sum += course_count
debug(float(courses_sum) / float(len(students)))

course_applicant_count = collections.defaultdict(int)
for student in students.keys():
    course_count, courses = students[student]
    for course in courses:
        applicant_count = course_applicant_count[course]
        applicant_count += 1
        course_applicant_count[course] = applicant_count

applicant_counts = sorted(list(course_applicant_count.items()),
                          key=operator.itemgetter(1), reverse=True)

course_applicants = collections.defaultdict(list)
for student in students.keys():
    course_count, courses = students[student]
    for course in courses:
        course_applicants[course].append(student)

course_applicant_sets = {}
for course, applicants in course_applicants.items():
    course_applicant_sets[course] = Students(course_applicants[course])

# First determine most similar courses to the 25 biggest courses
initial_courses = [c[0] for c in applicant_counts[0:25]]
courses_left = set(all_courses) - set(initial_courses)
debug(len(initial_courses), len(courses_left))
similar_courses = collections.defaultdict(list)

current_spot = 1
while len(courses_left) > 0:
    if len(courses_left) % 100 == 0:
        debug(u"{0}/{1}".format(len(courses_left), len(all_courses)))

    heap = []
    initial_course = initial_courses[current_spot - 1]
    for course, applicant_count in applicant_counts:
        if course not in courses_left:
            continue

        set_overlap = \
            course_applicant_sets[initial_course].intersection(course_applicant_sets[course]).__len__()
        heapq.heappush(heap, (1000 - set_overlap, course))

    best = heapq.heappop(heap)[1]
    similar_courses[current_spot].append(best)
    courses_left.remove(best)

    current_spot += 1
    if current_spot > 25:
        current_spot = 1

for index, course in enumerate(initial_courses):
    print(course, index + 1)

for spot in similar_courses:
    current_spot = 1
    courses = similar_courses[spot]

    for course in courses:
        print(course, current_spot)

        current_spot += 1
        if current_spot > 25:
            current_spot = 1
