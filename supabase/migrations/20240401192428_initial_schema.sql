create extension if not exists "vector" with schema "public" version '0.6.0';

create sequence "public"."testembeds_id_seq";

create table "public"."resume_description_embeddings" (
    "id" bigint not null default nextval('testembeds_id_seq'::regclass),
    "embedding" vector(1536) not null,
    "resume_entry_id" bigint,
    "description" text not null
);


create table "public"."resume_entries" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "position_title" character varying,
    "company_name" character varying,
    "start_date" date,
    "end_date" date,
    "description" text
);


create table "public"."testembeds" (
    "id" bigint not null default nextval('testembeds_id_seq'::regclass),
    "content" text,
    "embedding" vector(1536)
);


alter sequence "public"."testembeds_id_seq" owned by "public"."testembeds"."id";

CREATE UNIQUE INDEX resume_entries_pkey ON public.resume_entries USING btree (id);

CREATE UNIQUE INDEX testembeds_duplicate_pkey ON public.resume_description_embeddings USING btree (id);

CREATE UNIQUE INDEX testembeds_pkey ON public.testembeds USING btree (id);

alter table "public"."resume_description_embeddings" add constraint "testembeds_duplicate_pkey" PRIMARY KEY using index "testembeds_duplicate_pkey";

alter table "public"."resume_entries" add constraint "resume_entries_pkey" PRIMARY KEY using index "resume_entries_pkey";

alter table "public"."testembeds" add constraint "testembeds_pkey" PRIMARY KEY using index "testembeds_pkey";

alter table "public"."resume_description_embeddings" add constraint "public_resume_description_embeddings_resume_entry_id_fkey" FOREIGN KEY (resume_entry_id) REFERENCES resume_entries(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."resume_description_embeddings" validate constraint "public_resume_description_embeddings_resume_entry_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_resume_entry(position_title character varying, company_name character varying, start_date date, end_date date, description text, descriptions text[], embeddings vector[])
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    success BOOLEAN := TRUE;
    temp_resume_entry_id INT;
    i INT;
BEGIN
    -- Insert into the first table
    INSERT INTO resume_entries (position_title, company_name, start_date, end_date, description) 
    VALUES (position_title, company_name, start_date, end_date, description) 
    RETURNING id INTO temp_resume_entry_id;

    -- Loop through the arrays of descriptions and embeddings and insert each one separately
    FOR i IN 1..array_length(embeddings, 1) LOOP
        INSERT INTO resume_description_embeddings (resume_entry_id, description, embedding) 
        VALUES (temp_resume_entry_id, descriptions[i], embeddings[i]::vector);
    END LOOP;

    -- Return success
    RETURN success;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.match_testembeds(query_embedding vector, match_threshold double precision, match_count integer)
 RETURNS TABLE(id bigint, content text, similarity double precision)
 LANGUAGE sql
 STABLE
AS $function$
  select
    testembeds.id,
    testembeds.content,
    1 - (testembeds.embedding <=> query_embedding) as similarity
  from testembeds
  where testembeds.embedding <=> query_embedding < 1 - match_threshold
  order by testembeds.embedding <=> query_embedding
  limit match_count;
$function$
;

grant delete on table "public"."resume_description_embeddings" to "anon";

grant insert on table "public"."resume_description_embeddings" to "anon";

grant references on table "public"."resume_description_embeddings" to "anon";

grant select on table "public"."resume_description_embeddings" to "anon";

grant trigger on table "public"."resume_description_embeddings" to "anon";

grant truncate on table "public"."resume_description_embeddings" to "anon";

grant update on table "public"."resume_description_embeddings" to "anon";

grant delete on table "public"."resume_description_embeddings" to "authenticated";

grant insert on table "public"."resume_description_embeddings" to "authenticated";

grant references on table "public"."resume_description_embeddings" to "authenticated";

grant select on table "public"."resume_description_embeddings" to "authenticated";

grant trigger on table "public"."resume_description_embeddings" to "authenticated";

grant truncate on table "public"."resume_description_embeddings" to "authenticated";

grant update on table "public"."resume_description_embeddings" to "authenticated";

grant delete on table "public"."resume_description_embeddings" to "service_role";

grant insert on table "public"."resume_description_embeddings" to "service_role";

grant references on table "public"."resume_description_embeddings" to "service_role";

grant select on table "public"."resume_description_embeddings" to "service_role";

grant trigger on table "public"."resume_description_embeddings" to "service_role";

grant truncate on table "public"."resume_description_embeddings" to "service_role";

grant update on table "public"."resume_description_embeddings" to "service_role";

grant delete on table "public"."resume_entries" to "anon";

grant insert on table "public"."resume_entries" to "anon";

grant references on table "public"."resume_entries" to "anon";

grant select on table "public"."resume_entries" to "anon";

grant trigger on table "public"."resume_entries" to "anon";

grant truncate on table "public"."resume_entries" to "anon";

grant update on table "public"."resume_entries" to "anon";

grant delete on table "public"."resume_entries" to "authenticated";

grant insert on table "public"."resume_entries" to "authenticated";

grant references on table "public"."resume_entries" to "authenticated";

grant select on table "public"."resume_entries" to "authenticated";

grant trigger on table "public"."resume_entries" to "authenticated";

grant truncate on table "public"."resume_entries" to "authenticated";

grant update on table "public"."resume_entries" to "authenticated";

grant delete on table "public"."resume_entries" to "service_role";

grant insert on table "public"."resume_entries" to "service_role";

grant references on table "public"."resume_entries" to "service_role";

grant select on table "public"."resume_entries" to "service_role";

grant trigger on table "public"."resume_entries" to "service_role";

grant truncate on table "public"."resume_entries" to "service_role";

grant update on table "public"."resume_entries" to "service_role";

grant delete on table "public"."testembeds" to "anon";

grant insert on table "public"."testembeds" to "anon";

grant references on table "public"."testembeds" to "anon";

grant select on table "public"."testembeds" to "anon";

grant trigger on table "public"."testembeds" to "anon";

grant truncate on table "public"."testembeds" to "anon";

grant update on table "public"."testembeds" to "anon";

grant delete on table "public"."testembeds" to "authenticated";

grant insert on table "public"."testembeds" to "authenticated";

grant references on table "public"."testembeds" to "authenticated";

grant select on table "public"."testembeds" to "authenticated";

grant trigger on table "public"."testembeds" to "authenticated";

grant truncate on table "public"."testembeds" to "authenticated";

grant update on table "public"."testembeds" to "authenticated";

grant delete on table "public"."testembeds" to "service_role";

grant insert on table "public"."testembeds" to "service_role";

grant references on table "public"."testembeds" to "service_role";

grant select on table "public"."testembeds" to "service_role";

grant trigger on table "public"."testembeds" to "service_role";

grant truncate on table "public"."testembeds" to "service_role";

grant update on table "public"."testembeds" to "service_role";


