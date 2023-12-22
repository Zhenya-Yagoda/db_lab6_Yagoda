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


