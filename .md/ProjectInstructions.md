# PROFESSOR'S INSTRUCTIONS

## COURSE ENROLLMENT SIMULATOR - INSTRUCTIONS AND RUBRICS  

### The Course Enrollment Simulator is designed to manage students, courses, and enrollment processes using object-oriented programming. The system focuses on three main classes: Student, Course, and Enrollment.  

#### Students should be able to:  
- Enroll in a course  
- Drop a course  
- View enrolled courses  

#### Courses should include:  
- Course code, title, and capacity  
- Validation to prevent over-enrollment  

#### Enrollment serves as the link between Student and Course.

#### Optional features:  
- Simple prerequisite checking  
- Basic grade input  

### PROCESS FLOW  
1. Student selects a course  
2. System checks availability  
3. Enrollment is created  
4. Student may drop course  
5. System updates records  

### RULES  
- Students can enroll in multiple courses  
- Courses can have multiple students  
- Capacity must not be exceeded  
- Each enrollment links one student and one course 


# MY ADDITIONAL INSTRUCTIONS (AN IMPROVED ONE) [FOLLOW THIS]

1. There should be two account within the system that is made possible by the login feauture: Student and Professor. 
    - For student: 
      - They should be able to enroll, drop and view courses.
      - They can enroll in multiple courses.
      - They can only enrol if the capacity of the course is not yet exceeded.
      - Along with the feature of being able enroll, there should be an additional info about the pre-requisites checking that will determine if they are able to enrol or not.
      - Each enrollment links one student and one course. 
    - For professor: 
      - They should be able to add or remove a course, update a course and confirm or reject an enrollment.
      - If the student completed the course, they could finally put a grade to that specific student. 
    - For the login feauture: students should enter their student ID which formats to (YYYY-CODE-LETTER for example 2023-2735-A) 
2. Example flow of the process would be:
   1. Student selects a course
   2. System checks availability
   3. Professor Confirms the enrollment
   4. Enrollment is created
   5. Student may drop course
   6. Student that completed a course can be graded by the professor.
   7. System updates records.














ProjectInstructions.md




 this file is the instruction that our teacher had given us for our project, it should be an app and it should be in flutter language.




Now, I have used Claude AI agent to build the application for me, and the implementation plan used (that Claude also created) is 







ImplementationPlan1st.md




 . The system works fine, but after surfing for a short time, I noticed that Claude did not follow some of the instructions. For example, in the 







ProjectInstructions.md#L4-6




 







ProjectInstructions.md#L24




 







ProjectInstructions.md#L27-28




 







ProjectInstructions.md#L20-21




 , it should be the student that enrols or drops a course, but in the system, it seems like everything is handled by a professor/admin, which means that they're the one that enrolls and confirms the enrollment instead of students enrolling and them confirming it. The second problem is I dont seem to see any drop course feature, etc.. 







Therefore I want you to check the 







ProjectInstructions.md




 because I have updated it, you cross examine the 







ProjectInstructions.md




 and 







ImplementationPlan1st.md




 and check if there are other discrepancies and fix them., while also implementing the improvements that I have added in 







ProjectInstructions.md




. After it, I need you to fill the 







ImplementationPlan2nd.md




 based on the changes and layout in there the full implementation plan (it will also serve as my documnetation and record). Then after doing this, edit the system to finally fix/improve it.










The above is the prompt and i have already started the development, but it was cut short, just rescan and continue the development
