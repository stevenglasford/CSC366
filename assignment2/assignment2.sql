--QUESTION 1--
--Find the names of all students who are friends
--with someone named Gabriel--
SELECT NAME
FROM Highschooler
WHERE ID in (SELECT ID1
             FROM FRIEND
             WHERE ID2 IN (SELECT ID
                           FROM Highschooler
                           WHERE name = 'Gabriel'));

--QUESTION 2--
--For every student who likes 2 or more grades younger than
--themselves, return that student's name and grade, and the
--name and grade of the student they like--
SELECT liker.name, liker.grade, likee.name, likee.grade
FROM (Highschooler JOIN Likes ON Highschooler.ID=Likes.ID1)
	 liker JOIN Highschooler likee ON liker.ID2=likee.ID
WHERE liker.grade >= likee.grade + 2;

--QUESTION 3--
--For every pair of students who both like each other, return
--the name and grade of both students. Include each pair only
--once, with the two names in alphabetical order.--
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM (SELECT L1.ID1, L1.ID2
      FROM Likes L1 JOIN Likes L2 ON
		(L1.ID1=L2.ID2 AND L1.ID2=L2.ID1)) L
	JOIN Highschooler H1 ON H1.ID=L.ID1
	JOIN Highschooler H2 ON H2.ID=L.ID2
WHERE H1.name <= H2.name
ORDER BY H1.name;

--QUESTION 4--
--Find all students who do not appear in the Likes table
--(as a student who likes or is liked) and return their names
--and grades. Sort by grade, then by name within each grade.--
SELECT grade, name
FROM ((SELECT ID1 LID FROM Likes)
       UNION
      (SELECT ID2 LID FROM Likes)) Loved
      FULL OUTER JOIN Highschooler ON Highschooler.ID=Loved.LID
WHERE lid IS NULL
ORDER BY grade, name;

--QUESTION 5--
--For every situation where student A likes student B, but
--we have no information about whom B likes (that is, B does 
--not appear as an ID1 in the Likes table), return A and B's 
--names and grades--
SELECT h1.name, h1.grade, A.name, A.grade
FROM Highschooler h1 JOIN
	(SELECT * FROM
	(SELECT * FROM Highschooler h2
	 WHERE h2.ID NOT IN
	(SELECT ID1 FROM Likes))
 		B JOIN Likes ON B.ID=Likes.ID2) A ON h1.ID=A.ID1;

--QUESTION 6--
--Find names and grades of grades of students who only have 
--friends in the same grade. Return the result sorted by
--grade, then by name within each grade.--
SELECT C.grade, C.name
FROM Highschooler C
WHERE NOT EXISTS
(SELECT A.ID
FROM Highschooler A JOIN Friend F ON A.ID=F.ID1
WHERE A.grade <> C.grade AND F.ID2=C.ID)
ORDER BY C.grade, C.name;

--QUESTION 7--
--For each student A who likes a student B where the two are not friends,
--find if they have a friend C in common (who can introduce them!).
--For all such trios, return the name and grade of A, B, and C.--
SELECT A.name a_name,
       A.grade A_Grade,
       B.name B_Name,
       B.grade B_Grade,
       C.name C_Name,
       C.grade C_Grade
FROM (SELECT L.ID1 ida, L.ID2 idb, A.ID1 idc
      FROM Friend A JOIN Likes L ON A.ID2=L.ID1
           JOIN Friend B ON B.ID1=L.ID2
WHERE A.ID1=B.ID2 AND (L.ID1, L.ID2)
      NOT IN (SELECT * FROM Friend)) AS M
      JOIN Highschooler A ON A.ID=M.ida
      JOIN Highschooler B on B.ID=M.idb
      JOIN Highschooler C on C.ID=M.idc;

--QUESTION 8--
--Find the difference between the number of students in the school
--and the number of different first names.--
--SELECT Difference(Highschooler,
--SELECT DISTINCT name
--FROM Highschooler);
SELECT (COUNT(*) - COUNT(DISTINCT name)) diff
FROM Highschooler;

--QUESTION 9--
--Find the name and grade of all students who are liked by more
--than one other student--
SELECT H.Name, H.Grade
FROM (SELECT ID2
      FROM Likes
      GROUP BY ID2
      HAVING COUNT(*) >= 2)
     M JOIN Highschooler H ON M.ID2=H.ID;
