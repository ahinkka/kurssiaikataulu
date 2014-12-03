import sys
import collections
import operator

def debug(*args, **kwargs):
    kwargs['file'] = sys.stderr
    return print(*args, **kwargs)

# Basic data structures
students = {}
students_total = None
courses_total = None
students_per_course = None

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

        students[student] = (course_count, courses)

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

current_spot = 1
for course, count in applicant_counts:
    print(course, current_spot)
    current_spot += 1

    if current_spot > 25:
        current_spot = 1

