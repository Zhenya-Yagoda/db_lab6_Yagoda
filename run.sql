-- drop table score;
-- drop table movie;
-- drop table director;
-- drop table star;
-- drop table writer;

-- select * from director;
-- select * from movie;
-- select * from score;
-- select * from star;
-- select * from writer;

DROP FUNCTION IF EXISTS get_movie_count_writer();

-- функція що повертає кількість фільмів в кожного сценариста
CREATE OR REPLACE FUNCTION get_movie_count_writer() RETURNS TABLE(writer_name varchar(50), movie_count bigint)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
		SELECT writer.name_w AS writer_name, COUNT(movie.id_movie) AS movie_count
		FROM writer 
		JOIN movie ON writer.id_writer = movie.id_writer
		GROUP BY writer.id_writer, writer.name_w;
END;
$$;

SELECT * FROM get_movie_count_writer();
------------------

--процедура перевіряє чи існує директор фільму в таблиці, якщо ні - то додає його в таблицю як новий директор з новим id
DROP PROCEDURE IF EXISTS add_director_if_not_exists;

CREATE OR REPLACE PROCEDURE add_director_if_not_exists(director_name VARCHAR(255))
LANGUAGE plpgsql
AS $$
DECLARE
    director_id INT;
BEGIN
    -- Перевірити, чи існує директор з вказаним іменем
    SELECT id_director INTO director_id FROM director WHERE name_d = director_name;

    IF director_id IS NULL THEN
        -- Знайти максимальне значення id_director
        SELECT COALESCE(MAX(id_director), 0) + 1 INTO director_id FROM director;

        -- Додати нового директора з унікальним id_director
        INSERT INTO director(id_director, name_d)
        VALUES(director_id, director_name);

        RAISE INFO 'Director "%" added successfully with id_director %.', director_name, director_id;
    ELSE
        RAISE INFO 'Director "%" already exists.', director_name;
    END IF;
END;
$$;

CALL add_director_if_not_exists('Quentin Tarantino');
CALL add_director_if_not_exists('Stanley Kubrick');

SELECT * FROM director
------------------
--тригер що перевіряє чи існує директор фільму в таблиці, якщо ні - то додає його в таблицю як новий директор з новим id у верхньому регістрі

-- Видаляємо тригер, якщо він вже існує
DROP TRIGGER IF EXISTS director_insert ON director;

-- Перший етап: створення тригерної функції
CREATE OR REPLACE FUNCTION upper_director_name() RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS
$$
BEGIN
 	NEW.name_d := UPPER(NEW.name_d);
    -- Перевірка, чи існує директор з таким ім'ям
    IF NOT EXISTS (SELECT 1 FROM director WHERE UPPER(name_d) = UPPER(NEW.name_d)) THEN
        -- Якщо директора немає, створюємо новий id_director та перетворюємо ім'я у верхній регістр
        NEW.id_director := COALESCE((SELECT MAX(id_director) + 1 FROM director), 1);
    ELSE
        -- Якщо директор вже існує, виводимо повідомлення
        RAISE NOTICE 'Директор  % вже існує', NEW.name_d;
		RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;

-- Другий етап: створення тригеру
CREATE TRIGGER director_insert
BEFORE INSERT ON director
FOR EACH ROW
EXECUTE FUNCTION upper_director_name();

-- Вставляємо новий рядок
INSERT INTO director(name_d) VALUES ('Quentin Tarantino');
INSERT INTO director(name_d) VALUES ('Christopher Nolan');
INSERT INTO director(name_d) VALUES ('William Friedkin');

-- Перевірка результатів
SELECT * FROM director;


