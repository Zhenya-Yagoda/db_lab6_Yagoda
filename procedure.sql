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

--перевіряє чи існує директор фільму в таблиці, якщо ні - то додає його в таблицю як новий директор з новим id
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
