from __future__ import print_function

import sys
import collections
import operator

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


#
# Course popularity; handle courses in popularity order, assign in loop to
# spots
#
course_applicant_count = collections.defaultdict(int)
for student in students.keys():
    course_count, courses = students[student]
    for course in courses:
        applicant_count = course_applicant_count[course]
        applicant_count += 1
        course_applicant_count[course] = applicant_count

applicant_counts = sorted(list(course_applicant_count.items()),
                          key=operator.itemgetter(1), reverse=True)

# current_spot = 1
# for course, count in applicant_counts:
#     print(course, current_spot)
#     current_spot += 1

#     if current_spot > 25:
#         current_spot = 1

course_applicants = collections.defaultdict(list)
for student in students.keys():
    course_count, courses = students[student]
    for course in courses:
        course_applicants[course].append(student)

course_applicant_sets = {}
for course, applicants in course_applicants.items():
    course_applicant_sets[course] = Students(course_applicants[course])

courses_left = set(all_courses)
current_spot = 1
previous_spots = {}
while len(courses_left) > 0:
    if len(courses_left) % 100 == 0:
        debug(u"{0}/{1}".format(len(courses_left), len(all_courses)))

    # Handle the first round differently as we don't have anything to compare to
    if current_spot not in previous_spots:
        first_course = None
        for course, count in applicant_counts:
            if course not in courses_left:
                continue
            first_course = course
            break
        assert first_course is not None

        previous_spots[current_spot] = first_course
        courses_left.remove(first_course)
        print(first_course, current_spot)
    else:
        previous_on_the_spot = previous_spots[current_spot]
        # Go through all courses left to find out with best score. Score is
        # the applicant set overlap of the courses subtracted from the
        # applicant set size of the candidate course.
        #
        # I.e. CANDIDATE-COURSE-APPLICANT-COUNT -
        #      SET-OVERLAP(CANDIDATE_COURSE-APPLICANTS,
        #                  CURRENT-SPOT-PREVIOUS-ROUND-APPLICANTS).
        #
        # Ideally this should be a score of all the previous courses on the
        # spot.
        best_score = None
        best_score_course = None

        for course, applicant_count in applicant_counts:
            if course not in courses_left:
                continue
            
            if best_score is not None and applicant_count < best_score:
                continue

            set_overlap = \
                course_applicant_sets[course].intersection(course_applicant_sets[previous_on_the_spot]).__len__()
            score = applicant_count - set_overlap

            if best_score is None or score > best_score:
                best_score = score
                best_score_course = course
        assert best_score_course is not None

        previous_spots[current_spot] = best_score_course
        courses_left.remove(best_score_course)
        print(best_score_course, current_spot)


    current_spot += 1
    if current_spot > 25:
        current_spot = 1


# for course, count in applicant_counts:
#     print(course, course_applicant_sets[course])
