-- ============================================================
-- QA Test Suite: public.test_data
-- ============================================================
-- Target:
--   PostgreSQL database: qa_lab
--   Table: public.test_data
--
-- Purpose:
--   Validate positive, negative and data-integrity scenarios.
--
-- Preconditions:
--   - PostgreSQL container is running and healthy.
--   - Table public.test_data exists.
--   - Baseline data contains:
--       id = 1
--       message = 'Docker volume test'
--
-- Scenarios:
--   QA-SQL-001  Valid INSERT and generated ID
--   QA-SQL-002  Duplicate PRIMARY KEY must be rejected
--   QA-SQL-003  NULL value in NOT NULL column must be rejected
--   QA-SQL-004  NULL value in nullable column must be accepted
--
-- Cleanup:
--   Test data changes are rolled back at the end.
--
-- Expected result:
--   All scenarios PASS and baseline data remains unchanged.
-- ============================================================

BEGIN;

-- QA-SQL-001: valid INSERT
DO $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO public.test_data (message)
    VALUES ('SQL QA positive test')
    RETURNING id INTO v_id;

    IF v_id IS NULL THEN
        RAISE EXCEPTION 'QA-SQL-001 FAIL: generated id is NULL';
    END IF;

    RAISE NOTICE 'QA-SQL-001 PASS: valid INSERT accepted and id generated (%)', v_id;
END
$$;

-- QA-SQL-002: duplicate PRIMARY KEY must be rejected
DO $$
BEGIN
    BEGIN
        INSERT INTO public.test_data (id, message)
        VALUES (1, 'Duplicate primary key test');

        RAISE EXCEPTION 'QA-SQL-002 FAIL: duplicate primary key was accepted';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'QA-SQL-002 PASS: duplicate primary key rejected';
    END;
END
$$;

-- QA-SQL-003: explicit NULL for NOT NULL column must be rejected
DO $$
BEGIN
    BEGIN
        INSERT INTO public.test_data (id, message)
        VALUES (NULL, 'NULL primary key test');

        RAISE EXCEPTION 'QA-SQL-003 FAIL: NULL id was accepted';
    EXCEPTION
        WHEN not_null_violation THEN
            RAISE NOTICE 'QA-SQL-003 PASS: NULL id rejected';
    END;
END
$$;

-- QA-SQL-004: message is nullable and NULL must be accepted
DO $$
DECLARE
    v_id integer;
    v_message text;
BEGIN
    INSERT INTO public.test_data (message)
    VALUES (NULL)
    RETURNING id, message INTO v_id, v_message;

    IF v_id IS NULL THEN
        RAISE EXCEPTION 'QA-SQL-004 FAIL: generated id is NULL';
    END IF;

    IF v_message IS NOT NULL THEN
        RAISE EXCEPTION 'QA-SQL-004 FAIL: message is not NULL';
    END IF;

    RAISE NOTICE 'QA-SQL-004 PASS: NULL message accepted';
END
$$;

ROLLBACK;

-- Final data-integrity check after rollback.
DO $$
DECLARE
    v_count integer;
BEGIN
    SELECT count(*)
    INTO v_count
    FROM public.test_data;

    IF v_count <> 1 THEN
        RAISE EXCEPTION
            'DATA-INTEGRITY FAIL: expected 1 row after rollback, found %',
            v_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.test_data
        WHERE id = 1
          AND message = 'Docker volume test'
    ) THEN
        RAISE EXCEPTION
            'DATA-INTEGRITY FAIL: baseline row is missing or changed';
    END IF;

    RAISE NOTICE 'DATA-INTEGRITY PASS: baseline data restored after test rollback';
END
$$;
