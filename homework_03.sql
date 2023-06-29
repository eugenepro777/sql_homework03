USE lesson_3;

/*
Отсортируйте данные по полю заработная плата (salary) в порядке: убывания; возрастания
*/
SELECT
	id,
    salary,
    firstname,
    lastname
FROM staff
ORDER BY salary DESC;

SELECT
	id,
    salary,
    firstname,
    lastname
FROM staff
ORDER BY salary;

/*
Выведите 5 максимальных заработных плат (saraly)
*/
SELECT
	id,
    salary,
    firstname,
    lastname
FROM staff
ORDER BY salary DESC
LIMIT 5;

/*
Посчитайте суммарную зарплату (salary) по каждой специальности (роst)
*/
SELECT	
    post,
    SUM(salary) AS 'Сумма'
FROM staff 
GROUP BY post;

/*
Найдите кол-во сотрудников с специальностью (post) «Рабочий» в возрасте от 24 до 49 лет включительно
*/
SELECT
	post AS "специальность",
    COUNT(*) AS "кол-во сотрудников"
FROM staff
WHERE post = "Рабочий" AND age BETWEEN 24 AND 49
GROUP BY post;

/*
Найдите количество специальностей
*/
SELECT
	post AS "специальность",
    COUNT(post) AS "кол-во сотрудников"
FROM staff
GROUP BY post;

/*
Выведите специальности, у которых средний возраст сотрудников меньше 30 лет
*/
-- Если 30 лет не включать то сотрудников со средним возрастом меньше 30 лет просто нет в выборке
SELECT
	post AS "специальность",
    AVG(age) AS avg_age
FROM staff
GROUP BY post
HAVING avg_age <= 30;

/*
Внутри каждой должности вывести ТОП-2 по ЗП (2 самых высокооплачиваемых сотрудника по ЗП внутри каждой должности)
*/
-- без JOIN так и не нашел решения
SELECT s1.post, s1.firstname, s1.lastname, s1.salary
FROM staff s1
LEFT JOIN staff s2 ON s1.post = s2.post AND s1.salary < s2.salary
GROUP BY s1.post, s1.firstname, s1.lastname, s1.salary
HAVING COUNT(*) < 2
ORDER BY s1.post, s1.salary DESC;

-- нашёл еще 2 варианта:
-- первый вариант с подзапросами
SELECT post, firstname, lastname, salary
FROM (
  SELECT post, firstname, lastname, salary,
    ROW_NUMBER() OVER (PARTITION BY post ORDER BY salary DESC) AS rn
  FROM staff
) AS subquery
WHERE rn <= 2;
-- второй вариант с подзапросами и временными переменными
SELECT t.post, t.firstname, t.lastname, t.salary
FROM (
  SELECT post, firstname, lastname, salary,
    CASE 
      WHEN @prev_post = post THEN @row_number := @row_number + 1
      ELSE @row_number := 1
    END as rownumber,
    @prev_post := post
  FROM staff, (SELECT @row_number := 0, @prev_post := '') as r
  ORDER BY post, salary DESC
) as t
WHERE t.rownumber <= 2;


/*Доп по базе данных для ВК(in progress):
-- Посчитать количество документов у каждого пользователя (doc, docx, html)
-- Посчитать лайки для моих документов (моих медиа)
*/
USE lesson_4;

-- Посчитать количество документов у каждого пользователя (doc, docx, html)
-- первый вариант
SELECT
	COUNT(id) AS count_docs,
    user_id,
    media_type_id,
    (SELECT firstname FROM users WHERE users.id = media.user_id) AS user_name,
    (SELECT lastname FROM users WHERE users.id = media.user_id) AS user_lastname,
    (SELECT email FROM users WHERE users.id = media.user_id) AS user_email
FROM media
WHERE media_type_id = 4
GROUP BY user_id
ORDER BY count_docs DESC;

-- второй вариант
SELECT
	COUNT(id) AS count_docs,
    user_id,
    (SELECT firstname FROM users WHERE users.id = media.user_id) AS user_name,
    (SELECT lastname FROM users WHERE users.id = media.user_id) AS user_lastname,
    (SELECT email FROM users WHERE users.id = media.user_id) AS user_email
FROM media
WHERE SUBSTRING(media.filename, -3, 3) = 'doc' OR SUBSTRING(media.filename, -4, 4) = 'docx' OR SUBSTRING(media.filename, -4, 4) = 'html'
GROUP BY user_id
ORDER BY count_docs DESC;


-- Посчитать лайки для моих документов (моих медиа)
  
SELECT
	COUNT(id) AS count_likes,    
    media_id,  
    (SELECT filename FROM media WHERE media.id = likes.media_id) AS media_name
FROM likes
GROUP BY media_id
ORDER BY count_likes DESC;