--
-- PostgreSQL database dump
--

\restrict sdYaarmjuMNYkjAekhsjShNslP6vaelG5x5IJ7BEJmQjwlWKDjHp1WqH9osY19o

-- Dumped from database version 17.10 (Debian 17.10-1.pgdg12+1)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: _attach_updated_at(text); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public._attach_updated_at(tbl text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format(
        'CREATE TRIGGER trg_%I_updated
         BEFORE UPDATE ON %I
         FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at()',
        tbl, tbl
    );
END;
$$;


ALTER FUNCTION public._attach_updated_at(tbl text) OWNER TO "user";

--
-- Name: decrease_favorite(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.decrease_favorite() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE destinations SET favorite_count = GREATEST(favorite_count - 1, 0)
    WHERE id = OLD.destination_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.decrease_favorite() OWNER TO "user";

--
-- Name: fn_enqueue_embedding_job(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.fn_enqueue_embedding_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR
        (TG_OP = 'UPDATE' AND (NEW.content <> OLD.content OR NEW.title <> OLD.title)))
       AND NEW.is_active = TRUE
    THEN
        INSERT INTO embedding_jobs (entity_type, entity_id, status)
        VALUES ('knowledge_entry', NEW.id, 'pending')
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_enqueue_embedding_job() OWNER TO "user";

--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_set_updated_at() OWNER TO "user";

--
-- Name: fn_update_session_on_message(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.fn_update_session_on_message() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE chat_sessions
    SET updated_at     = NOW(),
        total_messages = total_messages + 1,
        total_tokens   = total_tokens
                         + COALESCE(NEW.prompt_tokens, 0)
                         + COALESCE(NEW.completion_tokens, 0)
    WHERE id = NEW.session_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_update_session_on_message() OWNER TO "user";

--
-- Name: increase_favorite(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.increase_favorite() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE destinations SET favorite_count = favorite_count + 1
    WHERE id = NEW.destination_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increase_favorite() OWNER TO "user";

--
-- Name: update_review_stats(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.update_review_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE destinations
    SET review_count = review_count + 1,
        rating_avg   = (
            SELECT COALESCE(AVG(rating), 0)
            FROM reviews WHERE destination_id = NEW.destination_id
        )
    WHERE id = NEW.destination_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_review_stats() OWNER TO "user";

--
-- Name: uuid_generate_v7(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.uuid_generate_v7() RETURNS uuid
    LANGUAGE sql
    AS $$
    SELECT encode(
        set_byte(
            set_byte(
                overlay(
                    gen_random_bytes(16)
                    PLACING substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
                    FROM 1 FOR 6
                ),
                6, (get_byte(gen_random_bytes(1), 0) & 15) | 112   -- version = 7
            ),
            8, (get_byte(gen_random_bytes(1), 0) & 63) | 128       -- variant = 10xx
        ),
        'hex'
    )::uuid;
$$;


ALTER FUNCTION public.uuid_generate_v7() OWNER TO "user";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.categories (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    icon character varying(100),
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO "user";

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.chat_messages (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    session_id uuid NOT NULL,
    role character varying(20) NOT NULL,
    content text NOT NULL,
    sources jsonb DEFAULT '[]'::jsonb,
    intent character varying(100),
    prompt_tokens integer DEFAULT 0,
    completion_tokens integer DEFAULT 0,
    latency_ms integer,
    feedback smallint,
    confidence_score double precision,
    search_method character varying(20),
    search_ms integer,
    llm_ms integer,
    cache_hit character varying(10),
    chunk_count integer,
    feedback_reason text,
    feedback_category character varying(50),
    feedback_resolved boolean,
    feedback_resolved_by uuid,
    suggested_questions jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chat_messages_feedback_check CHECK ((feedback = ANY (ARRAY['-1'::integer, 1]))),
    CONSTRAINT chat_messages_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying, 'system'::character varying])::text[])))
);


ALTER TABLE public.chat_messages OWNER TO "user";

--
-- Name: chat_sessions; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.chat_sessions (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(300),
    summary text,
    model_name character varying(100) DEFAULT 'gemini-1.5-flash'::character varying,
    total_messages integer DEFAULT 0,
    total_tokens integer DEFAULT 0,
    pinned boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    tags text[] DEFAULT '{}'::text[],
    is_flagged boolean DEFAULT false,
    last_itinerary jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.chat_sessions OWNER TO "user";

--
-- Name: cities; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.cities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug character varying(100) NOT NULL,
    name character varying(200) NOT NULL,
    province character varying(100),
    old_aliases text[] DEFAULT '{}'::text[] NOT NULL,
    region character varying(50),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cities OWNER TO "user";

--
-- Name: content_items; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.content_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content_type character varying(50) NOT NULL,
    city_slug character varying(120),
    name character varying(300) NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    image_url text,
    status character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.content_items OWNER TO "user";

--
-- Name: content_options; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.content_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content_type character varying(50) NOT NULL,
    field character varying(50) NOT NULL,
    code character varying(100) NOT NULL,
    label character varying(200) NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.content_options OWNER TO "user";

--
-- Name: conversation_memory; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.conversation_memory (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    memory_type character varying(50) NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    confidence numeric(4,3) DEFAULT 0.8,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT conversation_memory_memory_type_check CHECK (((memory_type)::text = ANY ((ARRAY['preference'::character varying, 'budget'::character varying, 'visited'::character varying, 'interested'::character varying, 'travel_style'::character varying])::text[])))
);


ALTER TABLE public.conversation_memory OWNER TO "user";

--
-- Name: destination_categories; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.destination_categories (
    destination_id uuid NOT NULL,
    category_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.destination_categories OWNER TO "user";

--
-- Name: destination_events; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.destination_events (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    event_date character varying(100),
    location_text text,
    cost character varying(100),
    description text,
    image_url text,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.destination_events OWNER TO "user";

--
-- Name: destination_view_logs; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.destination_view_logs (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    view_date character varying(10) NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.destination_view_logs OWNER TO "user";

--
-- Name: destination_view_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.destination_view_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.destination_view_logs_id_seq OWNER TO "user";

--
-- Name: destination_view_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.destination_view_logs_id_seq OWNED BY public.destination_view_logs.id;


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.destinations (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(100),
    province character varying(100),
    region character varying(50),
    description text,
    best_season character varying(200),
    best_months smallint[],
    weather text,
    cuisine text,
    budget_low integer,
    budget_high integer,
    image_url text,
    special text,
    rating_avg numeric(2,1) DEFAULT 0,
    review_count integer DEFAULT 0,
    favorite_count integer DEFAULT 0,
    view_count integer DEFAULT 0,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    city_id uuid,
    CONSTRAINT destinations_budget_high_check CHECK ((budget_high >= 0)),
    CONSTRAINT destinations_budget_low_check CHECK ((budget_low >= 0)),
    CONSTRAINT destinations_check CHECK (((budget_high IS NULL) OR (budget_high >= budget_low)))
);


ALTER TABLE public.destinations OWNER TO "user";

--
-- Name: email_verifications; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.email_verifications (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    is_verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.email_verifications OWNER TO "user";

--
-- Name: embedding_jobs; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.embedding_jobs (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    entity_type character varying(50) DEFAULT 'knowledge_entry'::character varying,
    entity_id uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    error text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT embedding_jobs_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'done'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.embedding_jobs OWNER TO "user";

--
-- Name: foods; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.foods (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid,
    name character varying(200) NOT NULL,
    local_name character varying(200),
    category character varying(50),
    description text,
    price_range character varying(100),
    must_try boolean DEFAULT false,
    vegetarian boolean DEFAULT false,
    tags text[],
    where_to_eat uuid[],
    image_url text,
    data_source text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.foods OWNER TO "user";

--
-- Name: hotels; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.hotels (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    type character varying(50),
    stars smallint,
    price_per_night integer,
    address text,
    amenities text[] DEFAULT '{}'::text[],
    description text,
    image_url text,
    rating numeric(3,2) DEFAULT 0,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hotels_price_per_night_check CHECK ((price_per_night >= 0)),
    CONSTRAINT hotels_stars_check CHECK (((stars >= 1) AND (stars <= 5))),
    CONSTRAINT hotels_type_check CHECK (((type)::text = ANY ((ARRAY['hotel'::character varying, 'homestay'::character varying, 'resort'::character varying, 'hostel'::character varying, 'villa'::character varying])::text[])))
);


ALTER TABLE public.hotels OWNER TO "user";

--
-- Name: intent_patterns; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.intent_patterns (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    intent character varying(50) NOT NULL,
    keyword character varying(200) NOT NULL,
    weight smallint DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT intent_patterns_weight_check CHECK ((weight >= 0))
);


ALTER TABLE public.intent_patterns OWNER TO "user";

--
-- Name: itineraries; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.itineraries (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid,
    city_slug character varying(80),
    title character varying(300) NOT NULL,
    duration_days smallint,
    group_type character varying(50),
    budget_low integer,
    budget_high integer,
    description text,
    tags text[] DEFAULT '{}'::text[],
    source character varying(100),
    data_source text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    cost_transport integer,
    cost_accommodation integer,
    cost_food integer,
    cost_activities integer,
    cost_other integer,
    CONSTRAINT itineraries_budget_high_check CHECK (((budget_high IS NULL) OR (budget_high >= 0))),
    CONSTRAINT itineraries_budget_low_check CHECK (((budget_low IS NULL) OR (budget_low >= 0))),
    CONSTRAINT itineraries_check CHECK (((budget_high IS NULL) OR (budget_low IS NULL) OR (budget_high >= budget_low))),
    CONSTRAINT itineraries_duration_days_check CHECK (((duration_days IS NULL) OR (duration_days >= 1))),
    CONSTRAINT itineraries_group_type_check CHECK (((group_type IS NULL) OR ((group_type)::text = ANY ((ARRAY['solo'::character varying, 'couple'::character varying, 'family'::character varying, 'group'::character varying])::text[]))))
);


ALTER TABLE public.itineraries OWNER TO "user";

--
-- Name: itinerary_items; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.itinerary_items (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    itinerary_id uuid NOT NULL,
    day_no smallint NOT NULL,
    order_no smallint DEFAULT 0,
    time_slot character varying(50),
    title character varying(300),
    description text,
    ref_type character varying(20),
    ref_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT itinerary_items_day_no_check CHECK ((day_no >= 1)),
    CONSTRAINT itinerary_items_ref_type_check CHECK (((ref_type IS NULL) OR ((ref_type)::text = ANY ((ARRAY['location'::character varying, 'hotel'::character varying, 'tour'::character varying, 'ticket'::character varying, 'transport'::character varying])::text[]))))
);


ALTER TABLE public.itinerary_items OWNER TO "user";

--
-- Name: knowledge_entries; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.knowledge_entries (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    title character varying(300) NOT NULL,
    category character varying(50) NOT NULL,
    destination_id uuid,
    city_slug character varying(80),
    content text NOT NULL,
    tags text[] DEFAULT '{}'::text[],
    source character varying(100),
    qdrant_id uuid,
    embedding public.vector(1024),
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    source_url text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT knowledge_entries_category_check CHECK (((category)::text = ANY ((ARRAY['destination'::character varying, 'hotel'::character varying, 'tour'::character varying, 'transport'::character varying, 'food'::character varying, 'activity'::character varying, 'shopping'::character varying, 'event'::character varying, 'safety'::character varying, 'faq'::character varying, 'tip'::character varying])::text[])))
);


ALTER TABLE public.knowledge_entries OWNER TO "user";

--
-- Name: COLUMN knowledge_entries.source; Type: COMMENT; Schema: public; Owner: user
--

COMMENT ON COLUMN public.knowledge_entries.source IS 'Convention KB→SQL: kb_md_faq | kb_md_experiences | kb_json_<type> (vd kb_json_food).';


--
-- Name: locations; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.locations (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid,
    name character varying(200) NOT NULL,
    type character varying(50),
    address text,
    lat numeric(10,7),
    lng numeric(10,7),
    hours character varying(200),
    description text,
    tips text,
    image_url text,
    rating_avg numeric(3,2) DEFAULT 0,
    review_count integer DEFAULT 0,
    verified boolean DEFAULT false,
    data_source text,
    source_url text,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.locations OWNER TO "user";

--
-- Name: locations_alias; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.locations_alias (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    old_name character varying(200) NOT NULL,
    new_slug character varying(80) NOT NULL,
    level character varying(20) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT locations_alias_level_check CHECK (((level)::text = ANY ((ARRAY['ward'::character varying, 'district'::character varying, 'province'::character varying])::text[])))
);


ALTER TABLE public.locations_alias OWNER TO "user";

--
-- Name: media_files; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.media_files (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename character varying(255) NOT NULL,
    original_name character varying(255),
    file_path text NOT NULL,
    file_size integer,
    mime_type character varying(100),
    width integer,
    height integer,
    tags text[] DEFAULT '{}'::text[],
    is_deleted boolean DEFAULT false,
    folder_id uuid,
    uploaded_by uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.media_files OWNER TO "user";

--
-- Name: media_folders; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.media_folders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    parent_id uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.media_folders OWNER TO "user";

--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.otp_codes (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid,
    email character varying(255) NOT NULL,
    code character varying(10) NOT NULL,
    purpose character varying(50) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT otp_codes_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['register'::character varying, 'reset_password'::character varying, 'change_email'::character varying])::text[])))
);


ALTER TABLE public.otp_codes OWNER TO "user";

--
-- Name: prompt_templates; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.prompt_templates (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(100) NOT NULL,
    system_prompt text NOT NULL,
    version character varying(20) DEFAULT '1.0'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.prompt_templates OWNER TO "user";

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.refresh_tokens OWNER TO "user";

--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.restaurants (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid,
    name character varying(200) NOT NULL,
    type character varying(50),
    address text,
    hours character varying(200),
    price_range character varying(100),
    specialties text[],
    description text,
    tips text,
    rating numeric(3,2),
    must_try boolean DEFAULT false,
    image_url text,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.restaurants OWNER TO "user";

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.reviews (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    rating integer,
    content text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO "user";

--
-- Name: shopping_places; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.shopping_places (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    type character varying(50),
    items text[] DEFAULT '{}'::text[],
    address text,
    opening_hours character varying(100),
    price_range character varying(100),
    image_url text,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT shopping_places_type_check CHECK (((type)::text = ANY ((ARRAY['market'::character varying, 'mall'::character varying, 'street'::character varying, 'specialty_store'::character varying, 'other'::character varying])::text[])))
);


ALTER TABLE public.shopping_places OWNER TO "user";

--
-- Name: system_configs; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.system_configs (
    key character varying(100) NOT NULL,
    value jsonb NOT NULL,
    description text,
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.system_configs OWNER TO "user";

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.tickets (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    location_id uuid,
    name character varying(200) NOT NULL,
    price_adult integer,
    price_child integer,
    description text,
    hours character varying(200),
    image_url text,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT tickets_price_adult_check CHECK ((price_adult >= 0)),
    CONSTRAINT tickets_price_child_check CHECK ((price_child >= 0))
);


ALTER TABLE public.tickets OWNER TO "user";

--
-- Name: tours; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.tours (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    duration character varying(50),
    price integer,
    group_size character varying(50),
    description text,
    includes text[] DEFAULT '{}'::text[],
    excludes text[] DEFAULT '{}'::text[],
    image_url text,
    data_source text,
    source_url text,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT tours_price_check CHECK ((price >= 0))
);


ALTER TABLE public.tours OWNER TO "user";

--
-- Name: transport_options; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.transport_options (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    destination_id uuid NOT NULL,
    is_local boolean DEFAULT false,
    type character varying(50) NOT NULL,
    price_info text,
    duration character varying(50),
    provider character varying(200),
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.transport_options OWNER TO "user";

--
-- Name: trip_plan_items; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.trip_plan_items (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    trip_plan_id uuid NOT NULL,
    day_number integer NOT NULL,
    order_in_day integer DEFAULT 0,
    title character varying(200),
    description text,
    location_id uuid,
    start_time time without time zone,
    end_time time without time zone,
    estimated_cost integer,
    notes text,
    CONSTRAINT trip_plan_items_check CHECK (((end_time IS NULL) OR (end_time >= start_time))),
    CONSTRAINT trip_plan_items_day_number_check CHECK ((day_number >= 1)),
    CONSTRAINT trip_plan_items_estimated_cost_check CHECK ((estimated_cost >= 0))
);


ALTER TABLE public.trip_plan_items OWNER TO "user";

--
-- Name: trip_plans; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.trip_plans (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    destination_id uuid,
    title character varying(300),
    budget integer,
    start_date date,
    end_date date,
    travelers integer DEFAULT 1,
    travel_type character varying(50),
    status character varying(20) DEFAULT 'draft'::character varying,
    ai_generated boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT trip_plans_budget_check CHECK ((budget >= 0)),
    CONSTRAINT trip_plans_check CHECK (((end_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT trip_plans_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'saved'::character varying, 'completed'::character varying])::text[]))),
    CONSTRAINT trip_plans_travel_type_check CHECK (((travel_type)::text = ANY ((ARRAY['solo'::character varying, 'couple'::character varying, 'family'::character varying, 'group'::character varying])::text[]))),
    CONSTRAINT trip_plans_travelers_check CHECK ((travelers > 0))
);


ALTER TABLE public.trip_plans OWNER TO "user";

--
-- Name: user_favorites; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.user_favorites (
    user_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_favorites OWNER TO "user";

--
-- Name: users; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(100),
    avatar_url text,
    role character varying(20) DEFAULT 'user'::character varying,
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    google_id character varying(255),
    auth_provider character varying(20) DEFAULT 'email'::character varying,
    CONSTRAINT users_auth_provider_check CHECK (((auth_provider)::text = ANY ((ARRAY['email'::character varying, 'google'::character varying, 'email+google'::character varying])::text[]))),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'moderator'::character varying, 'content_manager'::character varying, 'admin'::character varying, 'super_admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO "user";

--
-- Name: destination_view_logs id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_view_logs ALTER COLUMN id SET DEFAULT nextval('public.destination_view_logs_id_seq'::regclass);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_sessions chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: cities cities_slug_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_slug_key UNIQUE (slug);


--
-- Name: content_items content_items_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.content_items
    ADD CONSTRAINT content_items_pkey PRIMARY KEY (id);


--
-- Name: content_options content_options_content_type_field_code_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.content_options
    ADD CONSTRAINT content_options_content_type_field_code_key UNIQUE (content_type, field, code);


--
-- Name: content_options content_options_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.content_options
    ADD CONSTRAINT content_options_pkey PRIMARY KEY (id);


--
-- Name: conversation_memory conversation_memory_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.conversation_memory
    ADD CONSTRAINT conversation_memory_pkey PRIMARY KEY (id);


--
-- Name: destination_categories destination_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_categories
    ADD CONSTRAINT destination_categories_pkey PRIMARY KEY (destination_id, category_id);


--
-- Name: destination_events destination_events_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_events
    ADD CONSTRAINT destination_events_pkey PRIMARY KEY (id);


--
-- Name: destination_view_logs destination_view_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_view_logs
    ADD CONSTRAINT destination_view_logs_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_slug_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_slug_key UNIQUE (slug);


--
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (id);


--
-- Name: email_verifications email_verifications_user_id_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_user_id_key UNIQUE (user_id);


--
-- Name: embedding_jobs embedding_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.embedding_jobs
    ADD CONSTRAINT embedding_jobs_pkey PRIMARY KEY (id);


--
-- Name: foods foods_destination_id_name_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_destination_id_name_key UNIQUE (destination_id, name);


--
-- Name: foods foods_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (id);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (id);


--
-- Name: intent_patterns intent_patterns_intent_keyword_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.intent_patterns
    ADD CONSTRAINT intent_patterns_intent_keyword_key UNIQUE (intent, keyword);


--
-- Name: intent_patterns intent_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.intent_patterns
    ADD CONSTRAINT intent_patterns_pkey PRIMARY KEY (id);


--
-- Name: itineraries itineraries_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT itineraries_pkey PRIMARY KEY (id);


--
-- Name: itinerary_items itinerary_items_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.itinerary_items
    ADD CONSTRAINT itinerary_items_pkey PRIMARY KEY (id);


--
-- Name: knowledge_entries knowledge_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.knowledge_entries
    ADD CONSTRAINT knowledge_entries_pkey PRIMARY KEY (id);


--
-- Name: locations_alias locations_alias_old_name_level_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.locations_alias
    ADD CONSTRAINT locations_alias_old_name_level_key UNIQUE (old_name, level);


--
-- Name: locations_alias locations_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.locations_alias
    ADD CONSTRAINT locations_alias_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: media_folders media_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_folders
    ADD CONSTRAINT media_folders_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: prompt_templates prompt_templates_name_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.prompt_templates
    ADD CONSTRAINT prompt_templates_name_key UNIQUE (name);


--
-- Name: prompt_templates prompt_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.prompt_templates
    ADD CONSTRAINT prompt_templates_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: shopping_places shopping_places_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.shopping_places
    ADD CONSTRAINT shopping_places_pkey PRIMARY KEY (id);


--
-- Name: system_configs system_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.system_configs
    ADD CONSTRAINT system_configs_pkey PRIMARY KEY (key);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tours tours_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_pkey PRIMARY KEY (id);


--
-- Name: transport_options transport_options_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.transport_options
    ADD CONSTRAINT transport_options_pkey PRIMARY KEY (id);


--
-- Name: trip_plan_items trip_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plan_items
    ADD CONSTRAINT trip_plan_items_pkey PRIMARY KEY (id);


--
-- Name: trip_plans trip_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plans
    ADD CONSTRAINT trip_plans_pkey PRIMARY KEY (id);


--
-- Name: destination_events uq_events_dest_name; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_events
    ADD CONSTRAINT uq_events_dest_name UNIQUE (destination_id, name);


--
-- Name: hotels uq_hotels_dest_name; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT uq_hotels_dest_name UNIQUE (destination_id, name);


--
-- Name: knowledge_entries uq_knowledge_dest_cat_title; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.knowledge_entries
    ADD CONSTRAINT uq_knowledge_dest_cat_title UNIQUE (destination_id, category, title);


--
-- Name: shopping_places uq_shopping_dest_name; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.shopping_places
    ADD CONSTRAINT uq_shopping_dest_name UNIQUE (destination_id, name);


--
-- Name: destination_view_logs uq_view_per_user_day; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_view_logs
    ADD CONSTRAINT uq_view_per_user_day UNIQUE (user_id, destination_id, view_date);


--
-- Name: user_favorites user_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_pkey PRIMARY KEY (user_id, destination_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_categories_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_categories_active ON public.categories USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_cities_province; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_cities_province ON public.cities USING btree (province);


--
-- Name: idx_content_items_city; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_content_items_city ON public.content_items USING btree (city_slug);


--
-- Name: idx_content_items_created; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_content_items_created ON public.content_items USING btree (created_at DESC);


--
-- Name: idx_content_items_type; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_content_items_type ON public.content_items USING btree (content_type);


--
-- Name: idx_content_options_lookup; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_content_options_lookup ON public.content_options USING btree (content_type, field, is_active);


--
-- Name: idx_dest_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_active ON public.destinations USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_dest_budget; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_budget ON public.destinations USING btree (budget_low, budget_high);


--
-- Name: idx_dest_cat_cat; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_cat_cat ON public.destination_categories USING btree (category_id);


--
-- Name: idx_dest_cat_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_cat_dest ON public.destination_categories USING btree (destination_id);


--
-- Name: idx_dest_fts; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_fts ON public.destinations USING gin (to_tsvector('simple'::regconfig, (((((name)::text || ' '::text) || (COALESCE(province, ''::character varying))::text) || ' '::text) || COALESCE(description, ''::text))));


--
-- Name: idx_dest_province; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_province ON public.destinations USING btree (province);


--
-- Name: idx_dest_region; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_dest_region ON public.destinations USING btree (region);


--
-- Name: idx_email_ver_email; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_email_ver_email ON public.email_verifications USING btree (email);


--
-- Name: idx_email_ver_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_email_ver_user ON public.email_verifications USING btree (user_id);


--
-- Name: idx_embjobs_pending; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_embjobs_pending ON public.embedding_jobs USING btree (status, created_at) WHERE ((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying])::text[]));


--
-- Name: idx_events_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_events_dest ON public.destination_events USING btree (destination_id);


--
-- Name: idx_fav_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_fav_dest ON public.user_favorites USING btree (destination_id);


--
-- Name: idx_fav_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_fav_user ON public.user_favorites USING btree (user_id);


--
-- Name: idx_foods_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_foods_dest ON public.foods USING btree (destination_id);


--
-- Name: idx_hotels_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_hotels_dest ON public.hotels USING btree (destination_id);


--
-- Name: idx_hotels_fts; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_hotels_fts ON public.hotels USING gin (to_tsvector('simple'::regconfig, (((name)::text || ' '::text) || COALESCE(address, ''::text))));


--
-- Name: idx_hotels_price; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_hotels_price ON public.hotels USING btree (price_per_night);


--
-- Name: idx_hotels_stars; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_hotels_stars ON public.hotels USING btree (stars);


--
-- Name: idx_intent_patterns_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_intent_patterns_active ON public.intent_patterns USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_intent_patterns_intent; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_intent_patterns_intent ON public.intent_patterns USING btree (intent);


--
-- Name: idx_itineraries_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_itineraries_active ON public.itineraries USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_itineraries_city; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_itineraries_city ON public.itineraries USING btree (city_slug);


--
-- Name: idx_itineraries_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_itineraries_dest ON public.itineraries USING btree (destination_id);


--
-- Name: idx_itineraries_tags; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_itineraries_tags ON public.itineraries USING gin (tags);


--
-- Name: idx_itinerary_items_itin; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_itinerary_items_itin ON public.itinerary_items USING btree (itinerary_id, day_no, order_no);


--
-- Name: idx_knowledge_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_active ON public.knowledge_entries USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_knowledge_category; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_category ON public.knowledge_entries USING btree (category);


--
-- Name: idx_knowledge_city_slug; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_city_slug ON public.knowledge_entries USING btree (city_slug);


--
-- Name: idx_knowledge_destination; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_destination ON public.knowledge_entries USING btree (destination_id);


--
-- Name: idx_knowledge_embedding; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_embedding ON public.knowledge_entries USING hnsw (embedding public.vector_cosine_ops);


--
-- Name: idx_knowledge_fts; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_fts ON public.knowledge_entries USING gin (to_tsvector('simple'::regconfig, (((title)::text || ' '::text) || content)));


--
-- Name: idx_knowledge_tags; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_knowledge_tags ON public.knowledge_entries USING gin (tags);


--
-- Name: idx_locations_alias_level; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_locations_alias_level ON public.locations_alias USING btree (level);


--
-- Name: idx_locations_alias_slug; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_locations_alias_slug ON public.locations_alias USING btree (new_slug);


--
-- Name: idx_locations_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_locations_dest ON public.locations USING btree (destination_id);


--
-- Name: idx_locations_type; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_locations_type ON public.locations USING btree (type);


--
-- Name: idx_media_files_folder; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_media_files_folder ON public.media_files USING btree (folder_id, created_at DESC);


--
-- Name: idx_media_files_not_deleted; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_media_files_not_deleted ON public.media_files USING btree (created_at DESC) WHERE (NOT is_deleted);


--
-- Name: idx_media_folders_parent; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_media_folders_parent ON public.media_folders USING btree (parent_id);


--
-- Name: idx_memory_type; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_memory_type ON public.conversation_memory USING btree (user_id, memory_type);


--
-- Name: idx_memory_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_memory_user ON public.conversation_memory USING btree (user_id);


--
-- Name: idx_messages_intent; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_messages_intent ON public.chat_messages USING btree (intent);


--
-- Name: idx_messages_search_method; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_messages_search_method ON public.chat_messages USING btree (search_method) WHERE (search_method IS NOT NULL);


--
-- Name: idx_messages_session; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_messages_session ON public.chat_messages USING btree (session_id, created_at);


--
-- Name: idx_otp_email_purpose; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_otp_email_purpose ON public.otp_codes USING btree (email, purpose, used, expires_at) WHERE (used = false);


--
-- Name: idx_otp_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_otp_user ON public.otp_codes USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_reftokens_active; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_reftokens_active ON public.refresh_tokens USING btree (revoked, expires_at) WHERE (revoked = false);


--
-- Name: idx_reftokens_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_reftokens_user ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_restaurants_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_restaurants_dest ON public.restaurants USING btree (destination_id);


--
-- Name: idx_review_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_review_dest ON public.reviews USING btree (destination_id);


--
-- Name: idx_sessions_flagged; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_sessions_flagged ON public.chat_sessions USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: idx_sessions_pinned; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_sessions_pinned ON public.chat_sessions USING btree (user_id, pinned) WHERE (pinned = true);


--
-- Name: idx_sessions_updated; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_sessions_updated ON public.chat_sessions USING btree (user_id, updated_at DESC) WHERE (is_deleted = false);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_sessions_user ON public.chat_sessions USING btree (user_id);


--
-- Name: idx_shopping_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_shopping_dest ON public.shopping_places USING btree (destination_id);


--
-- Name: idx_tickets_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_tickets_dest ON public.tickets USING btree (destination_id);


--
-- Name: idx_tickets_location; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_tickets_location ON public.tickets USING btree (location_id);


--
-- Name: idx_tours_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_tours_dest ON public.tours USING btree (destination_id);


--
-- Name: idx_tours_fts; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_tours_fts ON public.tours USING gin (to_tsvector('simple'::regconfig, (((name)::text || ' '::text) || COALESCE(description, ''::text))));


--
-- Name: idx_tours_price; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_tours_price ON public.tours USING btree (price);


--
-- Name: idx_transport_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_transport_dest ON public.transport_options USING btree (destination_id);


--
-- Name: idx_transport_local; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_transport_local ON public.transport_options USING btree (destination_id, is_local);


--
-- Name: idx_trip_items_plan; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_trip_items_plan ON public.trip_plan_items USING btree (trip_plan_id, day_number);


--
-- Name: idx_trips_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_trips_dest ON public.trip_plans USING btree (destination_id);


--
-- Name: idx_trips_user; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_trips_user ON public.trip_plans USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_google_id; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_users_google_id ON public.users USING btree (google_id) WHERE (google_id IS NOT NULL);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: idx_view_log_dest; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX idx_view_log_dest ON public.destination_view_logs USING btree (destination_id);


--
-- Name: uq_media_folders_child_name; Type: INDEX; Schema: public; Owner: user
--

CREATE UNIQUE INDEX uq_media_folders_child_name ON public.media_folders USING btree (parent_id, name) WHERE (parent_id IS NOT NULL);


--
-- Name: uq_media_folders_root_name; Type: INDEX; Schema: public; Owner: user
--

CREATE UNIQUE INDEX uq_media_folders_root_name ON public.media_folders USING btree (name) WHERE (parent_id IS NULL);


--
-- Name: uq_transport_dest_type_provider; Type: INDEX; Schema: public; Owner: user
--

CREATE UNIQUE INDEX uq_transport_dest_type_provider ON public.transport_options USING btree (destination_id, type, COALESCE(provider, ''::character varying), COALESCE(duration, ''::character varying));


--
-- Name: categories trg_categories_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_categories_updated BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: chat_sessions trg_chat_sessions_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_chat_sessions_updated BEFORE UPDATE ON public.chat_sessions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: conversation_memory trg_conversation_memory_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_conversation_memory_updated BEFORE UPDATE ON public.conversation_memory FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: destinations trg_destinations_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_destinations_updated BEFORE UPDATE ON public.destinations FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: embedding_jobs trg_embedding_jobs_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_embedding_jobs_updated BEFORE UPDATE ON public.embedding_jobs FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: user_favorites trg_favorite_delete; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_favorite_delete AFTER DELETE ON public.user_favorites FOR EACH ROW EXECUTE FUNCTION public.decrease_favorite();


--
-- Name: user_favorites trg_favorite_insert; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_favorite_insert AFTER INSERT ON public.user_favorites FOR EACH ROW EXECUTE FUNCTION public.increase_favorite();


--
-- Name: foods trg_foods_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_foods_updated BEFORE UPDATE ON public.foods FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: hotels trg_hotels_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_hotels_updated BEFORE UPDATE ON public.hotels FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: intent_patterns trg_intent_patterns_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_intent_patterns_updated BEFORE UPDATE ON public.intent_patterns FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: itineraries trg_itineraries_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_itineraries_updated BEFORE UPDATE ON public.itineraries FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: knowledge_entries trg_knowledge_embedding; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_knowledge_embedding AFTER INSERT OR UPDATE ON public.knowledge_entries FOR EACH ROW EXECUTE FUNCTION public.fn_enqueue_embedding_job();


--
-- Name: knowledge_entries trg_knowledge_entries_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_knowledge_entries_updated BEFORE UPDATE ON public.knowledge_entries FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: locations trg_locations_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_locations_updated BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: prompt_templates trg_prompt_templates_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_prompt_templates_updated BEFORE UPDATE ON public.prompt_templates FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: restaurants trg_restaurants_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_restaurants_updated BEFORE UPDATE ON public.restaurants FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: reviews trg_review_insert; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_review_insert AFTER INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.update_review_stats();


--
-- Name: tours trg_tours_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_tours_updated BEFORE UPDATE ON public.tours FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trip_plans trg_trip_plans_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_trip_plans_updated BEFORE UPDATE ON public.trip_plans FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: chat_messages trg_update_session_on_message; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_update_session_on_message AFTER INSERT ON public.chat_messages FOR EACH ROW EXECUTE FUNCTION public.fn_update_session_on_message();


--
-- Name: users trg_users_updated; Type: TRIGGER; Schema: public; Owner: user
--

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: chat_messages chat_messages_feedback_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_feedback_resolved_by_fkey FOREIGN KEY (feedback_resolved_by) REFERENCES public.users(id);


--
-- Name: chat_messages chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_sessions(id) ON DELETE CASCADE;


--
-- Name: chat_sessions chat_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: conversation_memory conversation_memory_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.conversation_memory
    ADD CONSTRAINT conversation_memory_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: destination_categories destination_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_categories
    ADD CONSTRAINT destination_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: destination_categories destination_categories_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_categories
    ADD CONSTRAINT destination_categories_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: destination_events destination_events_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_events
    ADD CONSTRAINT destination_events_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: destination_view_logs destination_view_logs_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_view_logs
    ADD CONSTRAINT destination_view_logs_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: destination_view_logs destination_view_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destination_view_logs
    ADD CONSTRAINT destination_view_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: destinations destinations_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id);


--
-- Name: email_verifications email_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: foods foods_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: hotels hotels_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: itineraries itineraries_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT itineraries_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE SET NULL;


--
-- Name: itinerary_items itinerary_items_itinerary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.itinerary_items
    ADD CONSTRAINT itinerary_items_itinerary_id_fkey FOREIGN KEY (itinerary_id) REFERENCES public.itineraries(id) ON DELETE CASCADE;


--
-- Name: knowledge_entries knowledge_entries_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.knowledge_entries
    ADD CONSTRAINT knowledge_entries_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE SET NULL;


--
-- Name: locations locations_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: media_files media_files_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT media_files_folder_id_fkey FOREIGN KEY (folder_id) REFERENCES public.media_folders(id) ON DELETE SET NULL;


--
-- Name: media_files media_files_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT media_files_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: media_folders media_folders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_folders
    ADD CONSTRAINT media_folders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: media_folders media_folders_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.media_folders
    ADD CONSTRAINT media_folders_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.media_folders(id) ON DELETE CASCADE;


--
-- Name: otp_codes otp_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: restaurants restaurants_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shopping_places shopping_places_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.shopping_places
    ADD CONSTRAINT shopping_places_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: system_configs system_configs_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.system_configs
    ADD CONSTRAINT system_configs_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: tickets tickets_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: tours tours_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: transport_options transport_options_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.transport_options
    ADD CONSTRAINT transport_options_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: trip_plan_items trip_plan_items_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plan_items
    ADD CONSTRAINT trip_plan_items_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: trip_plan_items trip_plan_items_trip_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plan_items
    ADD CONSTRAINT trip_plan_items_trip_plan_id_fkey FOREIGN KEY (trip_plan_id) REFERENCES public.trip_plans(id) ON DELETE CASCADE;


--
-- Name: trip_plans trip_plans_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plans
    ADD CONSTRAINT trip_plans_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE SET NULL;


--
-- Name: trip_plans trip_plans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.trip_plans
    ADD CONSTRAINT trip_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_favorites user_favorites_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: user_favorites user_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict sdYaarmjuMNYkjAekhsjShNslP6vaelG5x5IJ7BEJmQjwlWKDjHp1WqH9osY19o

