
--WEEK ONE ASSIGNMENT
-- PART 1 SECTION A
-- Q1. Create the schema and set the search path to use it
create schema nairobi_academy;

show search_path;

set search_path to nairobi_academy;


-- Q2. Create the students table

create table students (
student_id SERIAL primary key,
first_name VARCHAR(50) not null,
last_name VARCHAR(50) not null,
gender CHAR(1) not null,
date_of_birth DATE,
class VARCHAR(13) not null,
city VARCHAR(20));

TRUNCATE TABLE students RESTART IDENTITY CASCADE;

select * from students;

-- Q3. Create the subjects table

create table subjects (
subject_id SERIAL primary key,
subject_name VARCHAR(50) not null,
department VARCHAR(50) not null,
teacher_name VARCHAR(50) not null,
credits INT);

select * from subjects;

-- Q4. Create the exam_results table

create table exam_results (
results_id SERIAL primary key,
student_id INT references students(student_id), -- foreign key
subject_id INT references subjects(subject_id), -- foreign key
marks INT,
exam_date DATE,
grade CHAR(1));

select * from exam_results;

-- Q5. Add phone_number column to students
alter table students
add column phone_number VARCHAR(20);

select * from students;

-- Q6. Rename credits column to credit_hours in subjects
alter table subjects
rename column credits to credit_hours;

select * from subjects;

-- Q7. Remove the phone_number column from students
alter table students
drop column phone_number;

select * from students;

--SECTION B
-- Q8 Insert students to table
INSERT INTO students (first_name, last_name, gender, class, city, date_of_birth)
VALUES
    ('Amina',   'Wanjiku',  'F', 'Form 3', 'Nairobi',  '2008-03-12'),
    ('Brian',   'Ochieng',  'M', 'Form 4', 'Mombasa',   '2007-07-25'),
    ('Cynthia', 'Mutua',    'F', 'Form 3', 'Kisumu',   '2008-11-05'),
    ('David',   'Kamau',    'M', 'Form 4', 'Nairobi',  '2007-02-18'),
    ('Esther',  'Akinyi',   'F', 'Form 2', 'Nakuru',   '2009-06-30'),
    ('Felix',   'Otieno',   'M', 'Form 2', 'Eldoret',  '2009-09-14'),
    ('Grace',   'Mwangi',   'F', 'Form 3', 'Nairobi',  '2008-01-22'),
    ('Hassan',  'Abdi',     'M', 'Form 4', 'Mombasa',  '2007-04-09'),
    ('Ivy',     'Chebet',   'F', 'Form 2', 'Nakuru',    '2009-12-01'),
    ('James',   'Kariuki',  'M', 'Form 3', 'Nairobi',  '2008-08-17');

truncate table students cascade;

select * from students;

INSERT INTO students (first_name, last_name, gender, class, city, date_of_birth)
VALUES
    ('Amina',   'Wanjiku',  'F', 'Form 3', 'Nairobi',  '2008-03-12'),
    ('Brian',   'Ochieng',  'M', 'Form 4', 'Mombasa',   '2007-07-25'),
    ('Cynthia', 'Mutua',    'F', 'Form 3', 'Kisumu',   '2008-11-05'),
    ('David',   'Kamau',    'M', 'Form 4', 'Nairobi',  '2007-02-18'),
    ('Esther',  'Akinyi',   'F', 'Form 2', 'Nakuru',   '2009-06-30'),
    ('Felix',   'Otieno',   'M', 'Form 2', 'Eldoret',  '2009-09-14'),
    ('Grace',   'Mwangi',   'F', 'Form 3', 'Nairobi',  '2008-01-22'),
    ('Hassan',  'Abdi',     'M', 'Form 4', 'Mombasa',  '2007-04-09'),
    ('Ivy',     'Chebet',   'F', 'Form 2', 'Nakuru',    '2009-12-01'),
    ('James',   'Kariuki',  'M', 'Form 3', 'Nairobi',  '2008-08-17');

-- Q9. Insert 10 subjects

INSERT INTO subjects (subject_name, department, teacher_name, credit_hours)
values
('Mathematics', 'Sciences','Mr.Njoroge', 4),
('English', 'Languages', 'Ms.Adhiambo', 3),
('Biology', 'Sciences', 'Ms.Otieno', 4),
('History', 'Humanities', 'Ms.Waweru', 3),
('Kiswahili', 'Languages', 'Ms.Nduta',3),
('Physics', 'Sciences', 'Mr.Kamande', 4),
('Geography', 'Humanities', 'Ms.Chebet', 3),
('Chemistry', 'Sciences', 'Ms.Muthoni', 4),
('Computer Studies', 'Sciences', 'Ms.Oduya', 3),
('Business Studies', 'Humanites', 'Ms. Wangari', 3);

-- Q10. Insert 10 exam results
INSERT INTO exam_results (results_id, student_id, subject_id, marks,exam_date, grade)
values
(1, 1, 1, 78, '2024-03-15', 'B'),
(2, 1, 2, 85, '2024-03-16', 'A'),
(3, 2, 1, 92, '2024-03-15', 'A'),
(4, 2, 3, 55, '2024-03-17', 'C'),
(5, 3, 2, 49, '2024-03-16', 'D'),
(6, 3, 4, 71, '2024-03-18', 'B'),
(7, 4, 1, 88, '2024-03-15', 'A'),
(8, 4, 6, 63, '2024-03-19', 'C'),
(9, 5, 5, 39, '2024-03-20', 'F'),
(10, 6, 9, 95, '2024-03-21', 'A');

select * from exam_results;

-- Q11. Confirm all 10 rows exist in each table

select * from students;
select * from exam_results;
select * from subjects;

-- Q12. Update Esther Akinyi's city from Nakuru to Nairobi (student_id = 5)
UPDATE students
SET city = 'Nairobi'
WHERE student_id = 5;

-- Q13. Fix marks for result_id 5 — correct value is 59
UPDATE exam_results
SET marks = 59
WHERE results_id = 5;

-- Q14. Delete the cancelled exam result (result_id = 9)
DELETE FROM exam_results
WHERE results_id = 9;

--SECTION C: QUERYING THE  DATA (WHERE)

-- Q15. All students in Form 4
select * from students
where class = 'Form 4';

-- Q16. All subjects in the Sciences department
select * from subjects
where department = 'Sciences';

-- Q17. Exam results where marks >= 70
select * from exam_results
where marks >=70;

-- Q18. Female students only
select * from students
where gender = 'F';

-- Q19. Students in Form 3 AND from Nairobi
select * from students
where class = 'Form 3' and city = 'Nairobi';

-- Q20. Students in Form 2 OR Form 4
select * from students
where class = 'Form 2' OR class ='Form 4';

================================================================================
-- PART 2 SECTION A: BETWEEN, IN, NOT IN, LIKE

-- Q1. Exam results where marks are between 50 and 80 (inclusive)
select * from exam_results
where marks between 50 and 80;

-- Q2. Exams that took place between 15th and 18th March 2024
select * from exam_results
where exam_date between '2024-03-15' and '2024-03-18';

-- Q3. Students who live in Nairobi, Mombasa, or Kisumu
select * from students
where city in ( 'Nairob', 'Mombasa', 'Kisumu');

-- Q4. Students NOT in Form 2 or Form 3
select * from students
where class not in ('Form 2', 'Form 3');

-- Q5. Students whose first name starts with 'A' or 'E'
select * from students
where first_name like 'A%'
or first_name like 'E%';

-- Q6. Subjects whose name contains the word 'Studies'
select * from subjects
where subject_name like '%Studies%';

-- PART 2 - SECTION B: COUNT

-- Q7. How many students are in Form 3?
select count (*) as total_form3_students
from students
where class = 'Form 3';

-- Q8. How many exam results have a mark of 70 or above?
select COUNT(*) as results_70_and_above
from exam_results
where marks >= 70;

-- Q9. Write a query using CASE WHEN to label each exam result with a grade description
select
    results_id,
    student_id,
    marks,
    case
        WHEN marks >= 80 THEN 'Distinction'
        WHEN marks >= 60 THEN 'Merit'
        WHEN marks >= 40 THEN 'Pass'
        ELSE 'Fail'
    END AS performance
FROM exam_results;

-- Q10. Label each student as Senior or Junior based on class
select
   first_name,
   last_name,
   class,
   case
         when class in ('Form 3', 'Form 4') then 'Senior'
         when class in ('Form 1', 'Form 2') then 'Junior'
   end as student_category
 from students;







































