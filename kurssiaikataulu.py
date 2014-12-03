import sys
import defaultdict

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
print(students_total, courses_total, students_per_course)
print(len(students))

courses_sum = 0
for student in students.keys():
    course_count, _ = students[student]
    courses_sum += course_count
print(float(courses_sum) / float(len(students)))

    
