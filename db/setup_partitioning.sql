CREATE OR REPLACE FUNCTION postings_insert_trigger()
	  RETURNS trigger AS $$
	    DECLARE
	    partition VARCHAR(25);
	    timestamp VARCHAR(35);
	    r postings%rowtype;

	    BEGIN
		partition := 'postings_' || to_char(NEW.created_at, 'DD_mon_YYYY');
		timestamp = NEW.created_at - interval '1 day';

		IF NOT EXISTS(SELECT 1 FROM pg_class WHERE relname = partition) THEN

			EXECUTE 'CREATE TABLE ' || partition || ' (
			  CHECK ( created_at::date >
				DATE ''' || timestamp || '''
				 AND created_at::date <= DATE ''' || NEW.created_at || ''' )
			   ) INHERITS (postings);';

			EXECUTE 'CREATE INDEX index_' || partition || '_on_category ON ' || partition || ' USING btree(category COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_category_group ON ' || partition || ' USING btree(category_group COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_city ON ' || partition || ' USING btree(city COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_country ON ' || partition || ' USING btree(country COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_county ON ' || partition || ' USING btree (county COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_id ON ' || partition || ' USING btree (id);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_locality ON ' || partition || ' USING btree (locality COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_metro ON ' || partition || ' USING btree (metro COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_region ON ' || partition || ' USING btree (region COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_source ON ' || partition || ' USING btree (source COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_state ON ' || partition || ' USING btree (state COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_status ON ' || partition || ' USING btree (status COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_zipcode ON ' || partition || ' USING btree (zipcode COLLATE pg_catalog.default);';
			EXECUTE 'CREATE INDEX index_' || partition || '_on_on_external_id_and_source ON ' || partition || ' USING btree (external_id COLLATE pg_catalog.default, source COLLATE pg_catalog.default);';

		END IF;

		EXECUTE 'INSERT INTO ' || partition || ' SELECT(postings ' || quote_literal(NEW) || ').*';


		RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_postings_trigger
  BEFORE INSERT
  ON postings
  FOR EACH ROW
  EXECUTE PROCEDURE postings_insert_trigger();

CREATE OR REPLACE FUNCTION postings_delete_master() RETURNS trigger
    AS $$
DECLARE
    r postings%rowtype;
BEGIN
    DELETE FROM ONLY postings where id = new.id returning * into r;
    RETURN r;
end;
$$
LANGUAGE plpgsql;

create trigger after_insert_postings_trigger
    after insert on postings
    for each row
        execute procedure postings_delete_master();

