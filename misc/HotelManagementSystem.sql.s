--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.0

-- Started on 2025-03-30 14:29:17 EDT

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
-- TOC entry 236 (class 1255 OID 17002)
-- Name: check_price_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_price_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- Check if the new price is greater than the minimum threshold
    IF NEW.price < 70 THEN
        RAISE EXCEPTION 'Price per night must be at least $70';
    END IF;
    
    -- Log the price change in the RoomPriceLog table
    INSERT INTO RoomPriceLog (room_id, old_price, new_price, changed_at)
    VALUES (NEW.room_id, OLD.price, NEW.price, NOW());
    
    -- Return the new row (continuing with the update)
    RETURN NEW;
END;
$_$;


ALTER FUNCTION public.check_price_update() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 17010)
-- Name: delete_chain_email_addresses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_chain_email_addresses() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM ChainEmailAddress WHERE chain_id = OLD.chain_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_chain_email_addresses() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 17012)
-- Name: delete_chain_phone_numbers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_chain_phone_numbers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM ChainPhoneNumber WHERE chain_id = OLD.chain_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_chain_phone_numbers() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 17024)
-- Name: delete_employees_from_hotel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_employees_from_hotel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Employee WHERE hotel_id = OLD.hotel_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_employees_from_hotel() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 17016)
-- Name: delete_hotel_phone_numbers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_hotel_phone_numbers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM HotelPhoneNumber WHERE hotel_id = OLD.hotel_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_hotel_phone_numbers() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 17014)
-- Name: delete_hotels_from_chain(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_hotels_from_chain() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Hotel WHERE chain_id = OLD.chain_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_hotels_from_chain() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 17004)
-- Name: delete_manager_from_manages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_manager_from_manages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the employee's role is "Manager"
    IF OLD.role = 'Manager' THEN
        -- Delete the employee's record from the 'Manages' table
        DELETE FROM Manages WHERE SSN = OLD.SSN AND hotel_id = OLD.hotel_id;
    END IF;
    
    -- Return the old employee data to complete the deletion
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_manager_from_manages() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 17018)
-- Name: delete_room_amenities(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_room_amenities() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM RoomAmenity WHERE room_id = OLD.room_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_room_amenities() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 17022)
-- Name: delete_room_problems(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_room_problems() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM RoomProblem WHERE room_id = OLD.room_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_room_problems() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 17020)
-- Name: delete_rooms_from_hotel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_rooms_from_hotel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Room WHERE hotel_id = OLD.hotel_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_rooms_from_hotel() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16838)
-- Name: hotel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotel (
    hotel_id character(8) NOT NULL,
    chain_id character(5) NOT NULL,
    address character varying(200) NOT NULL,
    num_rooms integer NOT NULL,
    contact_email character varying(100) NOT NULL,
    star_category integer NOT NULL,
    CONSTRAINT hotel_contact_email_check CHECK (((contact_email)::text ~~ '%@%.%'::text)),
    CONSTRAINT hotel_hotel_id_check CHECK ((hotel_id ~ '^HTL[0-9]{5}$'::text)),
    CONSTRAINT hotel_num_rooms_check CHECK ((num_rooms > 0)),
    CONSTRAINT hotel_star_category_check CHECK (((star_category >= 1) AND (star_category <= 5)))
);


ALTER TABLE public.hotel OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16889)
-- Name: room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.room (
    room_id character(10) NOT NULL,
    hotel_id character(8) NOT NULL,
    price numeric(10,2) NOT NULL,
    capacity character varying(10),
    view character varying(200),
    extendable boolean NOT NULL,
    status character varying(20) DEFAULT 'Available'::character varying,
    CONSTRAINT check_status CHECK (((status)::text = ANY (ARRAY[('Available'::character varying)::text, ('Unavailable'::character varying)::text]))),
    CONSTRAINT room_capacity_check CHECK (((capacity)::text = ANY ((ARRAY['SINGLE'::character varying, 'DOUBLE'::character varying, 'TRIPLE'::character varying, 'SUITE'::character varying, 'QUAD'::character varying])::text[]))),
    CONSTRAINT room_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE public.room OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17035)
-- Name: aggregated_room_capacity_per_hotel; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aggregated_room_capacity_per_hotel AS
 SELECT hotel.hotel_id,
    sum(
        CASE
            WHEN ((room.capacity)::text = 'SINGLE'::text) THEN 1
            WHEN ((room.capacity)::text = 'DOUBLE'::text) THEN 2
            WHEN ((room.capacity)::text = 'TRIPLE'::text) THEN 3
            WHEN ((room.capacity)::text = 'QUAD'::text) THEN 4
            WHEN ((room.capacity)::text = 'SUITE'::text) THEN 5
            ELSE 0
        END) AS total_capacity
   FROM (public.hotel
     JOIN public.room ON ((room.hotel_id = hotel.hotel_id)))
  GROUP BY hotel.hotel_id;


ALTER VIEW public.aggregated_room_capacity_per_hotel OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17030)
-- Name: available_rooms_per_area; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.available_rooms_per_area AS
 SELECT
        CASE
            WHEN ((hotel.address)::text ~~ '%Centretown%'::text) THEN 'Centretown'::text
            WHEN ((hotel.address)::text ~~ '%The Glebe%'::text) THEN 'The Glebe'::text
            WHEN ((hotel.address)::text ~~ '%Byward Market%'::text) THEN 'Byward Market'::text
            WHEN ((hotel.address)::text ~~ '%Rockcliffe Park%'::text) THEN 'Rockcliffe Park'::text
            WHEN ((hotel.address)::text ~~ '%Westboro%'::text) THEN 'Westboro'::text
            WHEN ((hotel.address)::text ~~ '%Old Ottawa East%'::text) THEN 'Old Ottawa East'::text
            WHEN ((hotel.address)::text ~~ '%Orleans%'::text) THEN 'Orleans'::text
            WHEN ((hotel.address)::text ~~ '%Kanata%'::text) THEN 'Kanata'::text
            WHEN ((hotel.address)::text ~~ '%Barrhaven%'::text) THEN 'Barrhaven'::text
            WHEN ((hotel.address)::text ~~ '%Nepean%'::text) THEN 'Nepean'::text
            WHEN ((hotel.address)::text ~~ '%Manotick%'::text) THEN 'Manotick'::text
            WHEN ((hotel.address)::text ~~ '%Stittsville%'::text) THEN 'Stittsville'::text
            WHEN ((hotel.address)::text ~~ '%New Edinburgh%'::text) THEN 'New Edinburgh'::text
            WHEN ((hotel.address)::text ~~ '%Sandy Hill%'::text) THEN 'Sandy Hill'::text
            WHEN ((hotel.address)::text ~~ '%Carleton Heights%'::text) THEN 'Carleton Heights'::text
            WHEN ((hotel.address)::text ~~ '%Carp%'::text) THEN 'Carp'::text
            WHEN ((hotel.address)::text ~~ '%Alta Vista%'::text) THEN 'Alta Vista'::text
            WHEN ((hotel.address)::text ~~ '%Little Italy%'::text) THEN 'Little Italy'::text
            WHEN ((hotel.address)::text ~~ '%Overbrook%'::text) THEN 'Overbrook'::text
            WHEN ((hotel.address)::text ~~ '%Cumberland%'::text) THEN 'Cumberland'::text
            ELSE 'Unknown Area'::text
        END AS area,
    count(room.room_id) AS available_rooms
   FROM (public.room room
     JOIN public.hotel hotel ON ((room.hotel_id = hotel.hotel_id)))
  WHERE ((room.status)::text = 'Available'::text)
  GROUP BY
        CASE
            WHEN ((hotel.address)::text ~~ '%Centretown%'::text) THEN 'Centretown'::text
            WHEN ((hotel.address)::text ~~ '%The Glebe%'::text) THEN 'The Glebe'::text
            WHEN ((hotel.address)::text ~~ '%Byward Market%'::text) THEN 'Byward Market'::text
            WHEN ((hotel.address)::text ~~ '%Rockcliffe Park%'::text) THEN 'Rockcliffe Park'::text
            WHEN ((hotel.address)::text ~~ '%Westboro%'::text) THEN 'Westboro'::text
            WHEN ((hotel.address)::text ~~ '%Old Ottawa East%'::text) THEN 'Old Ottawa East'::text
            WHEN ((hotel.address)::text ~~ '%Orleans%'::text) THEN 'Orleans'::text
            WHEN ((hotel.address)::text ~~ '%Kanata%'::text) THEN 'Kanata'::text
            WHEN ((hotel.address)::text ~~ '%Barrhaven%'::text) THEN 'Barrhaven'::text
            WHEN ((hotel.address)::text ~~ '%Nepean%'::text) THEN 'Nepean'::text
            WHEN ((hotel.address)::text ~~ '%Manotick%'::text) THEN 'Manotick'::text
            WHEN ((hotel.address)::text ~~ '%Stittsville%'::text) THEN 'Stittsville'::text
            WHEN ((hotel.address)::text ~~ '%New Edinburgh%'::text) THEN 'New Edinburgh'::text
            WHEN ((hotel.address)::text ~~ '%Sandy Hill%'::text) THEN 'Sandy Hill'::text
            WHEN ((hotel.address)::text ~~ '%Carleton Heights%'::text) THEN 'Carleton Heights'::text
            WHEN ((hotel.address)::text ~~ '%Carp%'::text) THEN 'Carp'::text
            WHEN ((hotel.address)::text ~~ '%Alta Vista%'::text) THEN 'Alta Vista'::text
            WHEN ((hotel.address)::text ~~ '%Little Italy%'::text) THEN 'Little Italy'::text
            WHEN ((hotel.address)::text ~~ '%Overbrook%'::text) THEN 'Overbrook'::text
            WHEN ((hotel.address)::text ~~ '%Cumberland%'::text) THEN 'Cumberland'::text
            ELSE 'Unknown Area'::text
        END;


ALTER VIEW public.available_rooms_per_area OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16931)
-- Name: booking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking (
    booking_id character(10) NOT NULL,
    customer_id character(10) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    room_id character(10) NOT NULL,
    CONSTRAINT booking_check CHECK ((end_date > start_date))
);


ALTER TABLE public.booking OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16816)
-- Name: chainemailaddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chainemailaddress (
    chain_id character(5) NOT NULL,
    email_address character varying(100) NOT NULL,
    CONSTRAINT chainemailaddress_email_address_check CHECK (((email_address)::text ~~ '%@%.%'::text))
);


ALTER TABLE public.chainemailaddress OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16827)
-- Name: chainphonenumber; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chainphonenumber (
    chain_id character(5) NOT NULL,
    phone_number character varying(20) NOT NULL,
    CONSTRAINT chainphonenumber_phone_number_check CHECK (((phone_number)::text ~* '^\s*(?:\+?\d{1,3})?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}(?: *x(\d+))?\s*$'::text))
);


ALTER TABLE public.chainphonenumber OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16953)
-- Name: checkin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkin (
    ssn character(9) NOT NULL,
    customer_id character(10) NOT NULL,
    booking_id character(10) NOT NULL
);


ALTER TABLE public.checkin OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16924)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id character(10) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    address character varying(200) NOT NULL,
    id_type character varying(20),
    id_number character varying(50) NOT NULL,
    registration_date date NOT NULL,
    CONSTRAINT customer_id_type_check CHECK (((id_type)::text = ANY ((ARRAY['SSN'::character varying, 'SIN'::character varying, 'DRIVING_LICENSE'::character varying])::text[]))),
    CONSTRAINT customer_registration_date_check CHECK ((registration_date <= CURRENT_DATE))
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16863)
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    ssn character(9) NOT NULL,
    hotel_id character(8) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    address character varying(200) NOT NULL,
    role character varying(100) NOT NULL,
    CONSTRAINT employee_ssn_check CHECK ((ssn ~ '^[0-9]{9}$'::text))
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16809)
-- Name: hotelchain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotelchain (
    chain_id character(5) NOT NULL,
    num_hotels integer NOT NULL,
    central_office_address character varying(200) NOT NULL,
    CONSTRAINT hotelchain_chain_id_check CHECK ((chain_id ~ '^CH[0-9]{3}$'::text)),
    CONSTRAINT hotelchain_num_hotels_check CHECK ((num_hotels > 0))
);


ALTER TABLE public.hotelchain OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16852)
-- Name: hotelphonenumber; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotelphonenumber (
    hotel_id character(8) NOT NULL,
    phone_number character varying(20) NOT NULL,
    CONSTRAINT hotelphonenumber_phone_number_check CHECK (((phone_number)::text ~* '^\s*(?:\+?\d{1,3})?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}(?: *x(\d+))?\s*$'::text))
);


ALTER TABLE public.hotelphonenumber OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16874)
-- Name: manages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manages (
    ssn character(9) NOT NULL,
    hotel_id character(8) NOT NULL
);


ALTER TABLE public.manages OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16942)
-- Name: rental; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rental (
    rental_id character(10) NOT NULL,
    customer_id character(10) NOT NULL,
    check_in_date date NOT NULL,
    check_out_date date NOT NULL,
    room_id character(10) NOT NULL,
    CONSTRAINT rental_check CHECK ((check_out_date > check_in_date))
);


ALTER TABLE public.rental OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16973)
-- Name: rents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rents (
    ssn character(9) NOT NULL,
    customer_id character(10) NOT NULL,
    room_id character(10) NOT NULL
);


ALTER TABLE public.rents OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16901)
-- Name: roomamenity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roomamenity (
    room_id character(10) NOT NULL,
    amenity character varying(20) NOT NULL,
    CONSTRAINT roomamenity_amenity_check CHECK (((amenity)::text = ANY ((ARRAY['TV'::character varying, 'AIR_CONDITION'::character varying, 'FRIDGE'::character varying, 'MINIBAR'::character varying, 'SAFE'::character varying, 'WIFI'::character varying, 'HAIRDRYER'::character varying, 'IRON'::character varying, 'COFFEE_MAKER'::character varying, 'MICROWAVE'::character varying, 'DESK'::character varying])::text[])))
);


ALTER TABLE public.roomamenity OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16995)
-- Name: roompricelog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roompricelog (
    log_id integer NOT NULL,
    room_id character(10) NOT NULL,
    old_price numeric(10,2),
    new_price numeric(10,2),
    changed_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.roompricelog OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16994)
-- Name: roompricelog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roompricelog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roompricelog_log_id_seq OWNER TO postgres;

--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 232
-- Name: roompricelog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roompricelog_log_id_seq OWNED BY public.roompricelog.log_id;


--
-- TOC entry 226 (class 1259 OID 16912)
-- Name: roomproblem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roomproblem (
    room_id character(10) NOT NULL,
    problem character varying(500) NOT NULL
);


ALTER TABLE public.roomproblem OWNER TO postgres;

--
-- TOC entry 3529 (class 2604 OID 16998)
-- Name: roompricelog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roompricelog ALTER COLUMN log_id SET DEFAULT nextval('public.roompricelog_log_id_seq'::regclass);


--
-- TOC entry 3771 (class 0 OID 16931)
-- Dependencies: 228
-- Data for Name: booking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking (booking_id, customer_id, start_date, end_date, room_id) FROM stdin;
\.


--
-- TOC entry 3761 (class 0 OID 16816)
-- Dependencies: 218
-- Data for Name: chainemailaddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chainemailaddress (chain_id, email_address) FROM stdin;
CH001	ch001@hotelsworld.com
CH002	ch002@hotelsworld.com
CH003	ch003@hotelsworld.com
CH004	ch004@hotelsworld.com
CH005	ch005@hotelsworld.com
\.


--
-- TOC entry 3762 (class 0 OID 16827)
-- Dependencies: 219
-- Data for Name: chainphonenumber; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chainphonenumber (chain_id, phone_number) FROM stdin;
CH001	+1-705-216-6999
CH002	+1-416-887-7556
CH003	+1-705-966-5316
CH004	+1-519-467-3921
CH005	+1-226-777-5877
\.


--
-- TOC entry 3773 (class 0 OID 16953)
-- Dependencies: 230
-- Data for Name: checkin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkin (ssn, customer_id, booking_id) FROM stdin;
\.


--
-- TOC entry 3770 (class 0 OID 16924)
-- Dependencies: 227
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (customer_id, first_name, last_name, address, id_type, id_number, registration_date) FROM stdin;
CUST3088  	Charlotte	Jones	117 Somerset St, Cumberland, Ottawa, Ontario, Canada	DRIVING_LICENSE	686187091	2025-02-02
CUST4405  	Jane	Anderson	456 Hunt Club Rd, Sandy Hill, Ottawa, Ontario, Canada	SIN	600651117	2023-10-20
CUST9346  	Robert	Martinez	794 Fourth St, Stittsville, Ottawa, Ontario, Canada	SSN	894818766	2022-09-18
CUST8800  	Megan	Gonzalez	563 Somerset St, Kanata, Ottawa, Ontario, Canada	DRIVING_LICENSE	773728087	2022-12-01
CUST7047  	Chris	Anderson	962 Elgin St, Rockcliffe Park, Ottawa, Ontario, Canada	SIN	391610921	2020-02-02
\.


--
-- TOC entry 3765 (class 0 OID 16863)
-- Dependencies: 222
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (ssn, hotel_id, first_name, last_name, address, role) FROM stdin;
421103059	HTL00100	Charlotte	Davis	238 Clyde Ave, Overbrook, Ottawa, Ontario, Canada	Housekeeper
317342261	HTL00100	Alex	Hernandez	344 Clyde Ave, Nepean, Ottawa, Ontario, Canada	Receptionist
899715065	HTL00100	Ethan	Brown	821 Catherine St, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
359700881	HTL00100	David	Taylor	709 Hunt Club Rd, Carleton Heights, Ottawa, Ontario, Canada	Chef
565036726	HTL00100	Olivia	Miller	663 Wellington St, Centretown, Ottawa, Ontario, Canada	Receptionist
336635564	HTL00100	Robert	White	559 Laurier Ave, Little Italy, Ottawa, Ontario, Canada	Security
862006326	HTL00100	Grace	Davis	672 Colonel By Dr, Stittsville, Ottawa, Ontario, Canada	Manager
184127303	HTL00101	James	Davis	292 St. Laurent Blvd, Rockcliffe Park, Ottawa, Ontario, Canada	Chef
899131696	HTL00101	Sophia	Jackson	169 Merivale Rd, The Glebe, Ottawa, Ontario, Canada	Receptionist
561915552	HTL00101	Matthew	Smith	242 King St, Westboro, Ottawa, Ontario, Canada	Receptionist
222141419	HTL00101	John	Lopez	160 Second St, Overbrook, Ottawa, Ontario, Canada	Chef
131546158	HTL00101	Charlotte	Thomas	186 Merivale Rd, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
900318961	HTL00101	Megan	Johnson	419 Fourth St, Manotick, Ottawa, Ontario, Canada	Manager
974364030	HTL00102	Sophia	Martinez	398 Second St, Westboro, Ottawa, Ontario, Canada	Receptionist
896741021	HTL00102	Daniel	Jones	132 Somerset St, Sandy Hill, Ottawa, Ontario, Canada	Housekeeper
281811571	HTL00102	James	Williams	201 Bronson Ave, Centretown, Ottawa, Ontario, Canada	Chef
539839965	HTL00102	Grace	White	984 Bronson Ave, Orleans, Ottawa, Ontario, Canada	Chef
819426329	HTL00102	Laura	Hernandez	476 Queen St, Orleans, Ottawa, Ontario, Canada	Security
386518171	HTL00102	James	Miller	331 Main St, Barrhaven, Ottawa, Ontario, Canada	Security
571040175	HTL00102	Robert	Johnson	704 Third St, Centretown, Ottawa, Ontario, Canada	Manager
958002734	HTL00103	Jane	Taylor	378 Bank St, New Edinburgh, Ottawa, Ontario, Canada	Housekeeper
854014594	HTL00103	Charlotte	Thomas	735 Laurier Ave, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
481270685	HTL00103	Alex	Garcia	621 Wellington St, Kanata, Ottawa, Ontario, Canada	Security
903081932	HTL00103	Olivia	Johnson	521 Gladstone Ave, Kanata, Ottawa, Ontario, Canada	Security
390840725	HTL00103	Charlotte	Gonzalez	806 Hunt Club Rd, Westboro, Ottawa, Ontario, Canada	Housekeeper
359925368	HTL00103	Katie	Davis	623 Queen St, Nepean, Ottawa, Ontario, Canada	Manager
890381418	HTL00104	Michael	White	691 Colonel By Dr, Carp, Ottawa, Ontario, Canada	Housekeeper
793756943	HTL00104	John	Wilson	784 Carling Ave, Little Italy, Ottawa, Ontario, Canada	Chef
124478753	HTL00104	Ethan	Brown	183 Catherine St, Nepean, Ottawa, Ontario, Canada	Housekeeper
406378527	HTL00104	Olivia	Martinez	866 Isabella St, Nepean, Ottawa, Ontario, Canada	Chef
883893587	HTL00104	John	Jackson	694 Laurier Ave, Westboro, Ottawa, Ontario, Canada	Receptionist
933002441	HTL00104	Emily	Garcia	724 Third St, Kanata, Ottawa, Ontario, Canada	Manager
911092050	HTL00105	Sarah	Miller	863 Clyde Ave, Byward Market, Ottawa, Ontario, Canada	Housekeeper
367981157	HTL00105	Katie	Taylor	546 Second St, Cumberland, Ottawa, Ontario, Canada	Receptionist
681932622	HTL00105	Sarah	Smith	313 Laurier Ave, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
908495255	HTL00105	Laura	Lopez	815 Clyde Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Chef
818998034	HTL00105	Katie	Davis	796 McArthur Ave, Kanata, Ottawa, Ontario, Canada	Housekeeper
373959366	HTL00105	Charlotte	Lopez	339 Main St, Centretown, Ottawa, Ontario, Canada	Housekeeper
949257555	HTL00105	Ethan	White	433 Carling Ave, Stittsville, Ottawa, Ontario, Canada	Manager
574619154	HTL00106	Laura	Martin	391 Isabella St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
846039828	HTL00106	Daniel	Martinez	412 Laurier Ave, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
195481819	HTL00106	John	Johnson	995 Lisgar St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
830218485	HTL00106	James	Miller	107 Clyde Ave, Carp, Ottawa, Ontario, Canada	Housekeeper
453702464	HTL00106	David	Taylor	447 Wellington St, Alta Vista, Ottawa, Ontario, Canada	Housekeeper
927078877	HTL00106	Sarah	Hernandez	369 Rideau St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
781107245	HTL00106	John	Gonzalez	219 Rideau St, Overbrook, Ottawa, Ontario, Canada	Manager
466245644	HTL00107	James	Garcia	588 Fourth St, Rockcliffe Park, Ottawa, Ontario, Canada	Security
140186740	HTL00107	Alex	White	683 Laurier Ave, Alta Vista, Ottawa, Ontario, Canada	Security
752645333	HTL00107	James	Brown	483 Third St, Carleton Heights, Ottawa, Ontario, Canada	Security
613843752	HTL00107	Matthew	White	825 Colonel By Dr, Westboro, Ottawa, Ontario, Canada	Housekeeper
422790089	HTL00107	James	Miller	160 Carling Ave, Barrhaven, Ottawa, Ontario, Canada	Receptionist
432550787	HTL00107	Grace	Jackson	170 Elgin St, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
684318041	HTL00107	Daniel	Davis	442 Gladstone Ave, Kanata, Ottawa, Ontario, Canada	Manager
288226815	HTL00108	Michael	Smith	986 Hunt Club Rd, Stittsville, Ottawa, Ontario, Canada	Housekeeper
880271818	HTL00108	Matthew	Jackson	668 Third St, Orleans, Ottawa, Ontario, Canada	Receptionist
790946976	HTL00108	John	Thomas	983 St. Laurent Blvd, Cumberland, Ottawa, Ontario, Canada	Chef
510413029	HTL00108	Megan	Thomas	799 Clyde Ave, Westboro, Ottawa, Ontario, Canada	Housekeeper
986111398	HTL00108	Grace	Brown	957 Wellington St, Byward Market, Ottawa, Ontario, Canada	Security
136411985	HTL00108	Daniel	Garcia	646 Main St, The Glebe, Ottawa, Ontario, Canada	Receptionist
789586452	HTL00108	Jane	White	761 McArthur Ave, Carleton Heights, Ottawa, Ontario, Canada	Manager
334889266	HTL00109	Jane	Martin	356 McArthur Ave, Cumberland, Ottawa, Ontario, Canada	Security
288293459	HTL00109	Grace	White	934 Queen St, Alta Vista, Ottawa, Ontario, Canada	Receptionist
317793188	HTL00109	David	Jones	967 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
300513135	HTL00109	Michael	Rodriguez	431 Second St, Nepean, Ottawa, Ontario, Canada	Security
718295565	HTL00109	Chris	Wilson	687 Queen St, Rockcliffe Park, Ottawa, Ontario, Canada	Housekeeper
444058545	HTL00109	Megan	Jones	955 Merivale Rd, Centretown, Ottawa, Ontario, Canada	Receptionist
301768079	HTL00109	Grace	Martin	365 Third St, The Glebe, Ottawa, Ontario, Canada	Manager
907822269	HTL00110	Laura	Rodriguez	761 Bank St, Sandy Hill, Ottawa, Ontario, Canada	Chef
916806997	HTL00110	Ethan	Martin	771 Elgin St, Little Italy, Ottawa, Ontario, Canada	Security
982365610	HTL00110	Katie	Johnson	821 Queen St, New Edinburgh, Ottawa, Ontario, Canada	Security
326836139	HTL00110	Katie	Garcia	391 Merivale Rd, Centretown, Ottawa, Ontario, Canada	Receptionist
473949616	HTL00110	Matthew	Moore	754 Rideau St, New Edinburgh, Ottawa, Ontario, Canada	Housekeeper
793120402	HTL00110	Laura	Johnson	362 Third St, Little Italy, Ottawa, Ontario, Canada	Manager
557443407	HTL00111	Chris	Jones	644 Carling Ave, Cumberland, Ottawa, Ontario, Canada	Housekeeper
441097930	HTL00111	Olivia	Taylor	711 Second St, Barrhaven, Ottawa, Ontario, Canada	Security
600656089	HTL00111	Katie	Smith	267 Carling Ave, Nepean, Ottawa, Ontario, Canada	Receptionist
677669136	HTL00111	Megan	White	518 Fourth St, The Glebe, Ottawa, Ontario, Canada	Security
600085755	HTL00111	John	Hernandez	648 Bronson Ave, Cumberland, Ottawa, Ontario, Canada	Manager
348519520	HTL00112	Charlotte	Thomas	934 Catherine St, Kanata, Ottawa, Ontario, Canada	Security
122896588	HTL00112	Olivia	Hernandez	439 King St, Old Ottawa East, Ottawa, Ontario, Canada	Security
468534776	HTL00112	James	Taylor	396 King St, Sandy Hill, Ottawa, Ontario, Canada	Security
792333527	HTL00112	Katie	Garcia	491 Third St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
765606266	HTL00112	Laura	Brown	137 Rideau St, Sandy Hill, Ottawa, Ontario, Canada	Security
658026735	HTL00112	Sophia	Lopez	991 Wellington St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
600613133	HTL00112	Ethan	Wilson	936 Wellington St, Rockcliffe Park, Ottawa, Ontario, Canada	Manager
691740273	HTL00113	Grace	Martinez	995 Rideau St, Westboro, Ottawa, Ontario, Canada	Chef
882681908	HTL00113	Charlotte	Jones	393 Laurier Ave, Kanata, Ottawa, Ontario, Canada	Housekeeper
562719717	HTL00113	William	Johnson	820 St. Laurent Blvd, Kanata, Ottawa, Ontario, Canada	Security
167568131	HTL00113	Sophia	Rodriguez	243 Queen St, Cumberland, Ottawa, Ontario, Canada	Chef
750967930	HTL00113	Sophia	Martin	413 Rideau St, Centretown, Ottawa, Ontario, Canada	Manager
598646773	HTL00114	Olivia	Gonzalez	675 Elgin St, Orleans, Ottawa, Ontario, Canada	Housekeeper
603546181	HTL00114	Laura	Moore	263 Rideau St, Little Italy, Ottawa, Ontario, Canada	Security
548797410	HTL00114	Katie	Williams	160 Gladstone Ave, Stittsville, Ottawa, Ontario, Canada	Housekeeper
714276388	HTL00114	Daniel	Davis	613 Hunt Club Rd, Overbrook, Ottawa, Ontario, Canada	Receptionist
802512466	HTL00114	David	Jackson	519 Catherine St, Rockcliffe Park, Ottawa, Ontario, Canada	Manager
586300414	HTL00115	Megan	Davis	599 Gladstone Ave, Cumberland, Ottawa, Ontario, Canada	Receptionist
492277909	HTL00115	Katie	Taylor	693 St. Laurent Blvd, Westboro, Ottawa, Ontario, Canada	Security
331119482	HTL00115	Katie	White	908 Gladstone Ave, Manotick, Ottawa, Ontario, Canada	Security
953880763	HTL00115	Megan	Garcia	335 Merivale Rd, Carp, Ottawa, Ontario, Canada	Housekeeper
653858242	HTL00115	Alex	Anderson	670 Bronson Ave, Old Ottawa East, Ottawa, Ontario, Canada	Security
301629484	HTL00115	David	Martin	669 Second St, Byward Market, Ottawa, Ontario, Canada	Chef
487987034	HTL00115	Jane	Brown	936 Third St, Stittsville, Ottawa, Ontario, Canada	Manager
593567760	HTL00116	Alex	Lopez	374 Catherine St, Byward Market, Ottawa, Ontario, Canada	Receptionist
697755016	HTL00116	Grace	Lopez	210 Queen St, Nepean, Ottawa, Ontario, Canada	Chef
807878893	HTL00116	William	Moore	182 Elgin St, Overbrook, Ottawa, Ontario, Canada	Receptionist
990334520	HTL00116	Grace	Moore	360 Bank St, Westboro, Ottawa, Ontario, Canada	Housekeeper
269467623	HTL00116	Olivia	Anderson	514 Isabella St, Stittsville, Ottawa, Ontario, Canada	Chef
907947484	HTL00116	Laura	Taylor	447 Bank St, New Edinburgh, Ottawa, Ontario, Canada	Manager
641186683	HTL00117	Ethan	Anderson	432 Clyde Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Security
178275194	HTL00117	Olivia	Jones	324 Rideau St, Cumberland, Ottawa, Ontario, Canada	Security
804673610	HTL00117	Megan	Hernandez	212 Merivale Rd, New Edinburgh, Ottawa, Ontario, Canada	Chef
525871549	HTL00117	Ethan	Johnson	103 Somerset St, Nepean, Ottawa, Ontario, Canada	Security
632030351	HTL00117	Alex	Hernandez	435 McArthur Ave, Centretown, Ottawa, Ontario, Canada	Chef
124291699	HTL00117	Grace	Smith	765 Somerset St, Byward Market, Ottawa, Ontario, Canada	Receptionist
264578664	HTL00117	Jane	Thomas	322 Main St, Orleans, Ottawa, Ontario, Canada	Manager
905749764	HTL00118	Chris	Wilson	970 Third St, Westboro, Ottawa, Ontario, Canada	Receptionist
608300171	HTL00118	Jane	Moore	274 Laurier Ave, Carp, Ottawa, Ontario, Canada	Chef
275694856	HTL00118	James	Thomas	709 Fourth St, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
280153039	HTL00118	Robert	Smith	734 Bank St, The Glebe, Ottawa, Ontario, Canada	Security
328228713	HTL00118	Alex	Thomas	883 Third St, Cumberland, Ottawa, Ontario, Canada	Manager
952265708	HTL00119	Katie	Taylor	158 Elgin St, Cumberland, Ottawa, Ontario, Canada	Receptionist
310642023	HTL00119	James	Moore	772 Third St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
863024965	HTL00119	Ethan	Martinez	214 Merivale Rd, Kanata, Ottawa, Ontario, Canada	Security
729551447	HTL00119	James	Jackson	410 Wellington St, Orleans, Ottawa, Ontario, Canada	Housekeeper
119105819	HTL00119	Daniel	Gonzalez	274 Queen St, Westboro, Ottawa, Ontario, Canada	Housekeeper
508716285	HTL00119	Grace	Smith	881 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	Chef
492210621	HTL00119	Chris	Williams	224 Bronson Ave, Kanata, Ottawa, Ontario, Canada	Manager
956503737	HTL00120	Laura	Martin	774 Bank St, Old Ottawa East, Ottawa, Ontario, Canada	Security
735784238	HTL00120	Jane	Williams	468 Fourth St, Little Italy, Ottawa, Ontario, Canada	Security
181730063	HTL00120	Emily	White	557 Isabella St, Carp, Ottawa, Ontario, Canada	Chef
284347023	HTL00120	Charlotte	Rodriguez	652 Bronson Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Chef
636336321	HTL00120	Laura	Smith	402 Wellington St, Westboro, Ottawa, Ontario, Canada	Manager
721363736	HTL00121	Chris	Smith	255 Bank St, Manotick, Ottawa, Ontario, Canada	Chef
203801887	HTL00121	Jane	Brown	790 Gladstone Ave, Orleans, Ottawa, Ontario, Canada	Security
382083510	HTL00121	Sarah	Jones	110 Catherine St, Orleans, Ottawa, Ontario, Canada	Housekeeper
663554582	HTL00121	John	Anderson	941 Carling Ave, Nepean, Ottawa, Ontario, Canada	Chef
842105924	HTL00121	Daniel	Hernandez	936 Third St, Carp, Ottawa, Ontario, Canada	Housekeeper
970609240	HTL00121	Sarah	Brown	777 Bank St, Alta Vista, Ottawa, Ontario, Canada	Chef
104215231	HTL00121	David	Smith	795 Second St, Nepean, Ottawa, Ontario, Canada	Manager
257020812	HTL00122	Laura	Garcia	599 Main St, Centretown, Ottawa, Ontario, Canada	Chef
810810529	HTL00122	Daniel	Gonzalez	400 Lisgar St, Carp, Ottawa, Ontario, Canada	Chef
127553511	HTL00122	Alex	Martin	925 Hunt Club Rd, Overbrook, Ottawa, Ontario, Canada	Chef
873657029	HTL00122	Megan	Jones	440 Carling Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
489034233	HTL00122	Laura	Smith	446 Wellington St, Kanata, Ottawa, Ontario, Canada	Manager
256837236	HTL00200	James	Wilson	186 Wellington St, Manotick, Ottawa, Ontario, Canada	Chef
859541908	HTL00200	James	Hernandez	491 Bank St, Carp, Ottawa, Ontario, Canada	Housekeeper
514166054	HTL00200	Charlotte	Hernandez	685 Second St, New Edinburgh, Ottawa, Ontario, Canada	Chef
738070204	HTL00200	William	Smith	379 Colonel By Dr, Old Ottawa East, Ottawa, Ontario, Canada	Chef
263708702	HTL00200	Chris	Davis	537 Bronson Ave, Kanata, Ottawa, Ontario, Canada	Manager
930878448	HTL00201	James	Lopez	602 Main St, Orleans, Ottawa, Ontario, Canada	Security
961485425	HTL00201	Megan	Gonzalez	754 Fourth St, The Glebe, Ottawa, Ontario, Canada	Chef
548825472	HTL00201	James	Smith	570 Hunt Club Rd, Centretown, Ottawa, Ontario, Canada	Chef
497119854	HTL00201	Chris	Miller	180 Wellington St, The Glebe, Ottawa, Ontario, Canada	Housekeeper
665800520	HTL00201	Ethan	White	333 Queen St, Old Ottawa East, Ottawa, Ontario, Canada	Security
570618242	HTL00201	Sophia	Garcia	192 Lisgar St, Nepean, Ottawa, Ontario, Canada	Manager
151631556	HTL00202	Charlotte	White	402 Elgin St, Sandy Hill, Ottawa, Ontario, Canada	Security
395830692	HTL00202	James	Lopez	200 St. Laurent Blvd, Carleton Heights, Ottawa, Ontario, Canada	Security
256977052	HTL00202	Megan	Davis	850 Clyde Ave, Little Italy, Ottawa, Ontario, Canada	Housekeeper
257953391	HTL00202	James	Martinez	808 Fourth St, Alta Vista, Ottawa, Ontario, Canada	Receptionist
986782990	HTL00202	Charlotte	Gonzalez	103 St. Laurent Blvd, Kanata, Ottawa, Ontario, Canada	Receptionist
587627136	HTL00202	John	Taylor	695 King St, Westboro, Ottawa, Ontario, Canada	Manager
964223009	HTL00203	William	Hernandez	575 Carling Ave, Centretown, Ottawa, Ontario, Canada	Security
421661846	HTL00203	Grace	Williams	596 Clyde Ave, Westboro, Ottawa, Ontario, Canada	Chef
270672383	HTL00203	Chris	Miller	437 Bronson Ave, Kanata, Ottawa, Ontario, Canada	Security
128433239	HTL00203	Sophia	Hernandez	969 Main St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
660692144	HTL00203	Emily	Williams	256 Gladstone Ave, Manotick, Ottawa, Ontario, Canada	Manager
333165479	HTL00204	Robert	Martin	976 Isabella St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
965749802	HTL00204	Jane	Wilson	196 McArthur Ave, Centretown, Ottawa, Ontario, Canada	Chef
156144867	HTL00204	Grace	Miller	201 Catherine St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
541442599	HTL00204	Alex	Jones	128 Bank St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
154857567	HTL00204	Matthew	Anderson	338 Gladstone Ave, Sandy Hill, Ottawa, Ontario, Canada	Security
557217318	HTL00204	Michael	Jones	953 Merivale Rd, Manotick, Ottawa, Ontario, Canada	Housekeeper
565627182	HTL00204	John	Jackson	300 Bronson Ave, Carleton Heights, Ottawa, Ontario, Canada	Manager
407037716	HTL00205	Katie	Lopez	835 St. Laurent Blvd, Overbrook, Ottawa, Ontario, Canada	Chef
941796911	HTL00205	Robert	Anderson	361 Bank St, New Edinburgh, Ottawa, Ontario, Canada	Security
314154180	HTL00205	Robert	Brown	916 Somerset St, Overbrook, Ottawa, Ontario, Canada	Housekeeper
213188584	HTL00205	Katie	Wilson	670 Third St, Orleans, Ottawa, Ontario, Canada	Housekeeper
385936707	HTL00205	Emily	Hernandez	226 Main St, Carp, Ottawa, Ontario, Canada	Chef
173606766	HTL00205	Laura	Garcia	568 Colonel By Dr, Centretown, Ottawa, Ontario, Canada	Manager
667008574	HTL00206	Olivia	Brown	420 McArthur Ave, Alta Vista, Ottawa, Ontario, Canada	Receptionist
128050857	HTL00206	Olivia	Wilson	673 Queen St, Rockcliffe Park, Ottawa, Ontario, Canada	Security
615758265	HTL00206	Jane	Taylor	677 Rideau St, Little Italy, Ottawa, Ontario, Canada	Housekeeper
105313343	HTL00206	Matthew	Thomas	189 Main St, Overbrook, Ottawa, Ontario, Canada	Security
669225062	HTL00206	Megan	Miller	566 St. Laurent Blvd, Kanata, Ottawa, Ontario, Canada	Security
717597461	HTL00206	David	Martinez	692 Bank St, Westboro, Ottawa, Ontario, Canada	Chef
655964054	HTL00206	Emily	Thomas	202 Second St, Manotick, Ottawa, Ontario, Canada	Manager
237691970	HTL00207	Robert	Brown	398 Queen St, Stittsville, Ottawa, Ontario, Canada	Chef
249160051	HTL00207	Ethan	Davis	939 Wellington St, Carp, Ottawa, Ontario, Canada	Chef
259237318	HTL00207	Megan	Lopez	282 Queen St, Orleans, Ottawa, Ontario, Canada	Housekeeper
456354976	HTL00207	Ethan	Davis	146 McArthur Ave, The Glebe, Ottawa, Ontario, Canada	Housekeeper
754161075	HTL00207	Sophia	Moore	588 Carling Ave, Westboro, Ottawa, Ontario, Canada	Manager
351668308	HTL00208	Chris	Johnson	274 Isabella St, Nepean, Ottawa, Ontario, Canada	Chef
740555181	HTL00208	Katie	Anderson	928 Laurier Ave, Barrhaven, Ottawa, Ontario, Canada	Chef
597816228	HTL00208	Emily	Smith	257 Elgin St, Little Italy, Ottawa, Ontario, Canada	Receptionist
403889082	HTL00208	Grace	Lopez	124 McArthur Ave, Cumberland, Ottawa, Ontario, Canada	Chef
678774583	HTL00208	Olivia	Martin	722 Colonel By Dr, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
444267140	HTL00208	Jane	Thomas	612 Second St, Kanata, Ottawa, Ontario, Canada	Security
709796852	HTL00208	Emily	Anderson	140 Lisgar St, Westboro, Ottawa, Ontario, Canada	Manager
499134593	HTL00209	Robert	White	619 Second St, Nepean, Ottawa, Ontario, Canada	Housekeeper
282957104	HTL00209	Katie	White	944 Hunt Club Rd, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
107731149	HTL00209	Grace	Anderson	605 Bank St, Overbrook, Ottawa, Ontario, Canada	Housekeeper
387116774	HTL00209	William	Davis	681 Clyde Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Housekeeper
515283781	HTL00209	James	Miller	388 Merivale Rd, Kanata, Ottawa, Ontario, Canada	Manager
230676131	HTL00210	Charlotte	Martin	836 Colonel By Dr, Byward Market, Ottawa, Ontario, Canada	Receptionist
365990955	HTL00210	Matthew	White	540 Second St, Cumberland, Ottawa, Ontario, Canada	Housekeeper
158245719	HTL00210	John	Taylor	191 Laurier Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
800324401	HTL00210	James	Jones	235 Second St, Overbrook, Ottawa, Ontario, Canada	Security
589219180	HTL00210	Charlotte	Miller	590 Lisgar St, Alta Vista, Ottawa, Ontario, Canada	Manager
715482716	HTL00211	Michael	Jones	869 Elgin St, Westboro, Ottawa, Ontario, Canada	Receptionist
953181448	HTL00211	David	Williams	426 Bronson Ave, Stittsville, Ottawa, Ontario, Canada	Security
221212708	HTL00211	Ethan	Davis	606 Fourth St, Cumberland, Ottawa, Ontario, Canada	Chef
473695673	HTL00211	James	Garcia	960 Isabella St, Carleton Heights, Ottawa, Ontario, Canada	Chef
281576565	HTL00211	William	Martinez	750 King St, Centretown, Ottawa, Ontario, Canada	Receptionist
336626677	HTL00211	Ethan	Moore	122 Elgin St, New Edinburgh, Ottawa, Ontario, Canada	Housekeeper
529845936	HTL00211	Olivia	Davis	114 Second St, Overbrook, Ottawa, Ontario, Canada	Manager
100024453	HTL00212	Megan	Williams	626 Hunt Club Rd, Orleans, Ottawa, Ontario, Canada	Receptionist
968769884	HTL00212	James	Hernandez	324 Bank St, Byward Market, Ottawa, Ontario, Canada	Receptionist
964760847	HTL00212	William	Martin	727 Merivale Rd, Barrhaven, Ottawa, Ontario, Canada	Security
170169516	HTL00212	Megan	Davis	726 Rideau St, Cumberland, Ottawa, Ontario, Canada	Receptionist
447660348	HTL00212	James	Brown	807 King St, Orleans, Ottawa, Ontario, Canada	Housekeeper
463564949	HTL00212	Megan	Miller	369 King St, New Edinburgh, Ottawa, Ontario, Canada	Manager
623479174	HTL00213	James	Wilson	529 Wellington St, Westboro, Ottawa, Ontario, Canada	Housekeeper
932807608	HTL00213	James	Thomas	382 Main St, Alta Vista, Ottawa, Ontario, Canada	Receptionist
856489454	HTL00213	Grace	Gonzalez	682 Bank St, Orleans, Ottawa, Ontario, Canada	Security
943690126	HTL00213	John	Johnson	472 Hunt Club Rd, Kanata, Ottawa, Ontario, Canada	Security
298187055	HTL00213	Michael	Lopez	511 Queen St, Overbrook, Ottawa, Ontario, Canada	Security
962494899	HTL00213	Laura	White	173 Gladstone Ave, Sandy Hill, Ottawa, Ontario, Canada	Chef
729603236	HTL00213	William	Smith	606 Rideau St, Old Ottawa East, Ottawa, Ontario, Canada	Manager
230240117	HTL00214	James	Wilson	788 Fourth St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
723468709	HTL00214	Robert	Williams	390 Bank St, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
270756989	HTL00214	Katie	Smith	370 Wellington St, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
784662390	HTL00214	Alex	Johnson	391 Laurier Ave, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
494839330	HTL00214	Sarah	Rodriguez	509 Colonel By Dr, Westboro, Ottawa, Ontario, Canada	Housekeeper
932068025	HTL00214	Sarah	Gonzalez	935 Elgin St, Cumberland, Ottawa, Ontario, Canada	Manager
421824908	HTL00215	Emily	Moore	372 Third St, Centretown, Ottawa, Ontario, Canada	Housekeeper
420469270	HTL00215	Chris	Thomas	796 Wellington St, Centretown, Ottawa, Ontario, Canada	Chef
655960549	HTL00215	James	Miller	222 Lisgar St, Nepean, Ottawa, Ontario, Canada	Housekeeper
952043201	HTL00215	Alex	Smith	640 Colonel By Dr, Barrhaven, Ottawa, Ontario, Canada	Security
542855157	HTL00215	Laura	Miller	541 Carling Ave, Sandy Hill, Ottawa, Ontario, Canada	Manager
989278916	HTL00216	Robert	Wilson	325 St. Laurent Blvd, Stittsville, Ottawa, Ontario, Canada	Chef
953618017	HTL00216	Katie	Smith	895 St. Laurent Blvd, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
357613156	HTL00216	Emily	Gonzalez	423 Queen St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
242605487	HTL00216	William	Jackson	598 Somerset St, The Glebe, Ottawa, Ontario, Canada	Security
428384545	HTL00216	James	Smith	843 Bronson Ave, Carp, Ottawa, Ontario, Canada	Chef
168246631	HTL00216	Ethan	Gonzalez	571 Lisgar St, New Edinburgh, Ottawa, Ontario, Canada	Security
339184595	HTL00216	Katie	Anderson	866 Third St, Nepean, Ottawa, Ontario, Canada	Manager
697592810	HTL00217	Charlotte	Thomas	497 Merivale Rd, Alta Vista, Ottawa, Ontario, Canada	Receptionist
257007243	HTL00217	James	Johnson	286 Second St, Kanata, Ottawa, Ontario, Canada	Chef
124918957	HTL00217	Alex	Moore	990 Second St, Manotick, Ottawa, Ontario, Canada	Housekeeper
590177409	HTL00217	James	Gonzalez	414 Colonel By Dr, Manotick, Ottawa, Ontario, Canada	Chef
582985278	HTL00217	Charlotte	Moore	550 Lisgar St, Manotick, Ottawa, Ontario, Canada	Housekeeper
101026982	HTL00217	William	Brown	940 King St, Alta Vista, Ottawa, Ontario, Canada	Manager
907792140	HTL00300	Katie	Martin	459 St. Laurent Blvd, New Edinburgh, Ottawa, Ontario, Canada	Receptionist
832861444	HTL00300	Sarah	Hernandez	263 Fourth St, New Edinburgh, Ottawa, Ontario, Canada	Housekeeper
801131755	HTL00300	Daniel	Taylor	708 Lisgar St, Carleton Heights, Ottawa, Ontario, Canada	Chef
805599137	HTL00300	Alex	Moore	990 St. Laurent Blvd, Carp, Ottawa, Ontario, Canada	Security
461747924	HTL00300	Laura	Brown	823 Elgin St, Cumberland, Ottawa, Ontario, Canada	Receptionist
579262660	HTL00300	Ethan	Wilson	120 Bank St, Overbrook, Ottawa, Ontario, Canada	Housekeeper
762283861	HTL00300	Sarah	Johnson	386 Fourth St, Byward Market, Ottawa, Ontario, Canada	Manager
180539025	HTL00301	Alex	Davis	564 Main St, Barrhaven, Ottawa, Ontario, Canada	Security
717899065	HTL00301	Jane	White	470 King St, Centretown, Ottawa, Ontario, Canada	Chef
982883412	HTL00301	Jane	Jackson	120 Clyde Ave, Barrhaven, Ottawa, Ontario, Canada	Receptionist
636108385	HTL00301	William	Jones	531 Elgin St, Carp, Ottawa, Ontario, Canada	Receptionist
329147851	HTL00301	Charlotte	White	878 Bronson Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Security
826649731	HTL00301	Alex	Jones	168 King St, New Edinburgh, Ottawa, Ontario, Canada	Manager
503497857	HTL00302	Sophia	Jackson	946 Isabella St, New Edinburgh, Ottawa, Ontario, Canada	Chef
435238219	HTL00302	Megan	Brown	719 Hunt Club Rd, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
569541609	HTL00302	John	Anderson	262 Colonel By Dr, Little Italy, Ottawa, Ontario, Canada	Housekeeper
535291021	HTL00302	Laura	Gonzalez	807 St. Laurent Blvd, Byward Market, Ottawa, Ontario, Canada	Chef
326518440	HTL00302	David	Rodriguez	292 Lisgar St, Little Italy, Ottawa, Ontario, Canada	Chef
142211662	HTL00302	Emily	Anderson	794 Bronson Ave, Carp, Ottawa, Ontario, Canada	Chef
496599344	HTL00302	Megan	Brown	192 Hunt Club Rd, Overbrook, Ottawa, Ontario, Canada	Manager
998508399	HTL00303	Ethan	Martinez	153 McArthur Ave, Centretown, Ottawa, Ontario, Canada	Chef
564264517	HTL00303	David	Martinez	943 Somerset St, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
780938285	HTL00303	Sophia	Davis	521 Queen St, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
361433831	HTL00303	Megan	Martinez	730 Gladstone Ave, Kanata, Ottawa, Ontario, Canada	Security
381387349	HTL00303	Olivia	Rodriguez	811 King St, Old Ottawa East, Ottawa, Ontario, Canada	Manager
379295331	HTL00304	John	Brown	414 Isabella St, The Glebe, Ottawa, Ontario, Canada	Security
317442533	HTL00304	Daniel	Johnson	591 King St, Overbrook, Ottawa, Ontario, Canada	Chef
136609576	HTL00304	Daniel	Davis	820 Queen St, Little Italy, Ottawa, Ontario, Canada	Housekeeper
235561364	HTL00304	Emily	Johnson	888 Isabella St, Nepean, Ottawa, Ontario, Canada	Security
445782885	HTL00304	Megan	Garcia	149 Bronson Ave, Carp, Ottawa, Ontario, Canada	Security
450231252	HTL00304	Sophia	Moore	746 Main St, Carleton Heights, Ottawa, Ontario, Canada	Manager
345552359	HTL00305	Jane	Garcia	239 Fourth St, Centretown, Ottawa, Ontario, Canada	Security
112577501	HTL00305	Katie	Moore	142 Laurier Ave, Carleton Heights, Ottawa, Ontario, Canada	Chef
234572940	HTL00305	Jane	Martin	654 Third St, Little Italy, Ottawa, Ontario, Canada	Security
502333078	HTL00305	Chris	Miller	866 Clyde Ave, Stittsville, Ottawa, Ontario, Canada	Receptionist
432856820	HTL00305	Sarah	Gonzalez	887 Third St, Westboro, Ottawa, Ontario, Canada	Security
273152270	HTL00305	Sarah	Moore	450 Colonel By Dr, New Edinburgh, Ottawa, Ontario, Canada	Manager
581062933	HTL00306	Sarah	Hernandez	864 Hunt Club Rd, Orleans, Ottawa, Ontario, Canada	Security
640823267	HTL00306	Grace	Lopez	441 Carling Ave, Kanata, Ottawa, Ontario, Canada	Receptionist
635751471	HTL00306	Charlotte	Jackson	895 McArthur Ave, Byward Market, Ottawa, Ontario, Canada	Housekeeper
903147402	HTL00306	Emily	Johnson	239 Isabella St, Carp, Ottawa, Ontario, Canada	Security
815991791	HTL00306	Katie	Thomas	624 Catherine St, Centretown, Ottawa, Ontario, Canada	Manager
814297595	HTL00307	Jane	Garcia	729 Bronson Ave, Alta Vista, Ottawa, Ontario, Canada	Security
831805247	HTL00307	Daniel	White	875 Lisgar St, Rockcliffe Park, Ottawa, Ontario, Canada	Chef
687063592	HTL00307	Katie	Williams	702 St. Laurent Blvd, Stittsville, Ottawa, Ontario, Canada	Chef
529779346	HTL00307	Laura	Gonzalez	400 Catherine St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
501075427	HTL00307	Matthew	White	643 Somerset St, The Glebe, Ottawa, Ontario, Canada	Manager
792060740	HTL00308	Sophia	Johnson	210 King St, Overbrook, Ottawa, Ontario, Canada	Receptionist
794791282	HTL00308	Chris	Johnson	830 Queen St, New Edinburgh, Ottawa, Ontario, Canada	Receptionist
272100021	HTL00308	Olivia	Jones	460 Catherine St, Rockcliffe Park, Ottawa, Ontario, Canada	Housekeeper
707819550	HTL00308	Daniel	Moore	781 Bank St, Kanata, Ottawa, Ontario, Canada	Receptionist
565681002	HTL00308	Charlotte	White	424 King St, Nepean, Ottawa, Ontario, Canada	Manager
595655931	HTL00309	Sarah	Gonzalez	353 Bank St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
443781292	HTL00309	Laura	Gonzalez	577 Isabella St, Cumberland, Ottawa, Ontario, Canada	Chef
761525082	HTL00309	Chris	Williams	811 Hunt Club Rd, The Glebe, Ottawa, Ontario, Canada	Receptionist
698273679	HTL00309	Olivia	Davis	735 Bank St, Sandy Hill, Ottawa, Ontario, Canada	Security
653122064	HTL00309	Katie	Johnson	705 Colonel By Dr, Orleans, Ottawa, Ontario, Canada	Manager
802311713	HTL00310	Sarah	Jones	213 Wellington St, Sandy Hill, Ottawa, Ontario, Canada	Chef
426318401	HTL00310	Robert	Williams	776 McArthur Ave, Little Italy, Ottawa, Ontario, Canada	Housekeeper
217486953	HTL00310	Emily	Miller	333 King St, Stittsville, Ottawa, Ontario, Canada	Chef
632207452	HTL00310	Katie	Wilson	655 Second St, Manotick, Ottawa, Ontario, Canada	Chef
590073669	HTL00310	Robert	Taylor	276 Carling Ave, Byward Market, Ottawa, Ontario, Canada	Security
300107250	HTL00310	John	Brown	568 Rideau St, The Glebe, Ottawa, Ontario, Canada	Manager
613014475	HTL00311	Michael	White	570 Laurier Ave, Byward Market, Ottawa, Ontario, Canada	Chef
275772882	HTL00311	Katie	Johnson	498 Laurier Ave, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
830815348	HTL00311	Alex	Jones	613 Rideau St, Westboro, Ottawa, Ontario, Canada	Housekeeper
798400593	HTL00311	John	Johnson	349 Bronson Ave, Westboro, Ottawa, Ontario, Canada	Chef
384679756	HTL00311	Robert	Johnson	170 Bronson Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Manager
527251115	HTL00312	Alex	Anderson	235 Rideau St, Old Ottawa East, Ottawa, Ontario, Canada	Security
510976072	HTL00312	Matthew	Davis	208 Queen St, Barrhaven, Ottawa, Ontario, Canada	Security
555733326	HTL00312	James	Wilson	117 Main St, Byward Market, Ottawa, Ontario, Canada	Chef
975235103	HTL00312	Jane	Johnson	315 Second St, Cumberland, Ottawa, Ontario, Canada	Receptionist
339209877	HTL00312	Charlotte	Taylor	153 McArthur Ave, Little Italy, Ottawa, Ontario, Canada	Manager
621246001	HTL00313	James	Jackson	572 Third St, Westboro, Ottawa, Ontario, Canada	Chef
176227340	HTL00313	Ethan	Johnson	733 Second St, Old Ottawa East, Ottawa, Ontario, Canada	Chef
241203150	HTL00313	Matthew	Jones	548 Clyde Ave, Byward Market, Ottawa, Ontario, Canada	Chef
484179997	HTL00313	Ethan	Wilson	985 Merivale Rd, Nepean, Ottawa, Ontario, Canada	Chef
569612023	HTL00313	Sophia	Taylor	508 Third St, Byward Market, Ottawa, Ontario, Canada	Manager
578846511	HTL00314	Chris	Taylor	793 Main St, Sandy Hill, Ottawa, Ontario, Canada	Housekeeper
292232036	HTL00314	John	Wilson	166 Isabella St, Centretown, Ottawa, Ontario, Canada	Chef
290581255	HTL00314	John	Jones	721 Elgin St, Orleans, Ottawa, Ontario, Canada	Housekeeper
751733835	HTL00314	Michael	White	321 Queen St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
690131804	HTL00314	Daniel	Martin	490 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
825492311	HTL00314	David	Garcia	400 Fourth St, Westboro, Ottawa, Ontario, Canada	Manager
591315179	HTL00315	Emily	Taylor	618 St. Laurent Blvd, Old Ottawa East, Ottawa, Ontario, Canada	Chef
431840101	HTL00315	Jane	Wilson	477 Elgin St, Nepean, Ottawa, Ontario, Canada	Security
727519980	HTL00315	Ethan	Rodriguez	544 Somerset St, Cumberland, Ottawa, Ontario, Canada	Receptionist
386134229	HTL00315	James	Moore	944 St. Laurent Blvd, Manotick, Ottawa, Ontario, Canada	Chef
163509478	HTL00315	James	Smith	404 Merivale Rd, Byward Market, Ottawa, Ontario, Canada	Housekeeper
367058815	HTL00315	James	Lopez	730 Catherine St, Kanata, Ottawa, Ontario, Canada	Security
757184903	HTL00315	Daniel	Gonzalez	407 Gladstone Ave, Overbrook, Ottawa, Ontario, Canada	Manager
463159829	HTL00400	Jane	Brown	748 Catherine St, Cumberland, Ottawa, Ontario, Canada	Chef
136693213	HTL00400	William	Lopez	157 Hunt Club Rd, Centretown, Ottawa, Ontario, Canada	Chef
305639250	HTL00400	William	Rodriguez	826 Third St, Little Italy, Ottawa, Ontario, Canada	Chef
940233801	HTL00400	John	Garcia	281 King St, Carleton Heights, Ottawa, Ontario, Canada	Chef
399164135	HTL00400	Sarah	Johnson	466 Somerset St, Carp, Ottawa, Ontario, Canada	Manager
215403976	HTL00401	John	Thomas	894 Catherine St, Centretown, Ottawa, Ontario, Canada	Chef
653922930	HTL00401	Jane	Smith	921 Main St, Stittsville, Ottawa, Ontario, Canada	Receptionist
665216937	HTL00401	Matthew	Taylor	850 King St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
728140342	HTL00401	Daniel	Taylor	127 Fourth St, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
334997917	HTL00401	Daniel	Thomas	383 Laurier Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Chef
436069321	HTL00401	Sophia	Gonzalez	243 Rideau St, New Edinburgh, Ottawa, Ontario, Canada	Manager
352742812	HTL00402	Alex	Brown	831 Third St, Carleton Heights, Ottawa, Ontario, Canada	Chef
455091742	HTL00402	Laura	Miller	662 Gladstone Ave, Carp, Ottawa, Ontario, Canada	Chef
458226984	HTL00402	Sarah	Jones	644 McArthur Ave, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
825176132	HTL00402	Laura	Taylor	654 Main St, Orleans, Ottawa, Ontario, Canada	Receptionist
939510900	HTL00402	Sarah	Johnson	423 Lisgar St, Barrhaven, Ottawa, Ontario, Canada	Chef
120167126	HTL00402	James	Davis	134 Catherine St, Kanata, Ottawa, Ontario, Canada	Housekeeper
167109071	HTL00402	John	Miller	613 McArthur Ave, Manotick, Ottawa, Ontario, Canada	Manager
382612444	HTL00403	Robert	Gonzalez	462 Bank St, Carp, Ottawa, Ontario, Canada	Chef
214123472	HTL00403	Sarah	Martinez	718 Rideau St, Cumberland, Ottawa, Ontario, Canada	Security
279382877	HTL00403	Matthew	Wilson	509 Second St, Barrhaven, Ottawa, Ontario, Canada	Chef
179234369	HTL00403	Sophia	Anderson	795 Queen St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
179164383	HTL00403	Ethan	Anderson	485 McArthur Ave, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
984619503	HTL00403	Sophia	Lopez	473 Queen St, Westboro, Ottawa, Ontario, Canada	Manager
354643660	HTL00404	Alex	Rodriguez	479 King St, Carp, Ottawa, Ontario, Canada	Housekeeper
198200992	HTL00404	Sophia	Taylor	826 Somerset St, Little Italy, Ottawa, Ontario, Canada	Housekeeper
400320069	HTL00404	James	Jackson	773 Isabella St, Alta Vista, Ottawa, Ontario, Canada	Security
258734285	HTL00404	Sophia	Smith	514 Carling Ave, The Glebe, Ottawa, Ontario, Canada	Receptionist
602741569	HTL00404	David	Miller	762 Rideau St, Manotick, Ottawa, Ontario, Canada	Manager
140591769	HTL00405	William	Jones	639 St. Laurent Blvd, Byward Market, Ottawa, Ontario, Canada	Security
331683726	HTL00405	Matthew	Jones	489 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	Security
831102319	HTL00405	Olivia	White	184 Colonel By Dr, Overbrook, Ottawa, Ontario, Canada	Chef
919524837	HTL00405	Matthew	Smith	819 Bank St, Overbrook, Ottawa, Ontario, Canada	Chef
508157738	HTL00405	John	Jackson	582 Second St, Kanata, Ottawa, Ontario, Canada	Receptionist
608591334	HTL00405	Alex	Smith	816 Rideau St, Barrhaven, Ottawa, Ontario, Canada	Receptionist
596703188	HTL00405	Charlotte	Wilson	173 St. Laurent Blvd, Nepean, Ottawa, Ontario, Canada	Manager
475610160	HTL00406	Alex	Jackson	241 Third St, New Edinburgh, Ottawa, Ontario, Canada	Security
903551811	HTL00406	Robert	Thomas	942 Colonel By Dr, Kanata, Ottawa, Ontario, Canada	Security
542914451	HTL00406	Michael	Williams	607 Catherine St, The Glebe, Ottawa, Ontario, Canada	Chef
402459003	HTL00406	David	Lopez	440 Fourth St, Stittsville, Ottawa, Ontario, Canada	Receptionist
886718557	HTL00406	Charlotte	Martinez	518 Clyde Ave, Westboro, Ottawa, Ontario, Canada	Receptionist
199104579	HTL00406	James	Hernandez	210 King St, Cumberland, Ottawa, Ontario, Canada	Housekeeper
658996615	HTL00406	Daniel	Williams	573 Laurier Ave, Old Ottawa East, Ottawa, Ontario, Canada	Manager
729604420	HTL00407	Sarah	Rodriguez	878 Second St, Alta Vista, Ottawa, Ontario, Canada	Receptionist
989413482	HTL00407	Sarah	White	187 Elgin St, Carp, Ottawa, Ontario, Canada	Housekeeper
761660687	HTL00407	Grace	Brown	176 Third St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
935771045	HTL00407	Katie	Martinez	612 Main St, The Glebe, Ottawa, Ontario, Canada	Chef
402906797	HTL00407	Sarah	Moore	719 Colonel By Dr, Rockcliffe Park, Ottawa, Ontario, Canada	Receptionist
848141446	HTL00407	William	Gonzalez	125 Laurier Ave, Centretown, Ottawa, Ontario, Canada	Manager
902079771	HTL00408	Matthew	White	287 Main St, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
283667053	HTL00408	Daniel	Anderson	846 Merivale Rd, Cumberland, Ottawa, Ontario, Canada	Housekeeper
662616533	HTL00408	Megan	Anderson	930 Isabella St, Carleton Heights, Ottawa, Ontario, Canada	Security
419973097	HTL00408	Grace	Rodriguez	897 Wellington St, Westboro, Ottawa, Ontario, Canada	Receptionist
229153897	HTL00408	Jane	Thomas	699 Hunt Club Rd, Little Italy, Ottawa, Ontario, Canada	Receptionist
318467305	HTL00408	Daniel	Lopez	909 Bank St, Nepean, Ottawa, Ontario, Canada	Housekeeper
704669251	HTL00408	Chris	Lopez	573 Somerset St, Overbrook, Ottawa, Ontario, Canada	Manager
849131734	HTL00409	Michael	Davis	365 Merivale Rd, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
607040038	HTL00409	Sarah	Anderson	222 Colonel By Dr, Stittsville, Ottawa, Ontario, Canada	Security
985705312	HTL00409	Robert	Anderson	828 Wellington St, Orleans, Ottawa, Ontario, Canada	Security
488418703	HTL00409	Daniel	Johnson	629 St. Laurent Blvd, Orleans, Ottawa, Ontario, Canada	Security
713062262	HTL00409	John	Martinez	717 Second St, Carleton Heights, Ottawa, Ontario, Canada	Chef
199642009	HTL00409	John	Hernandez	296 Carling Ave, Westboro, Ottawa, Ontario, Canada	Security
144159414	HTL00409	James	Thomas	544 Carling Ave, Barrhaven, Ottawa, Ontario, Canada	Manager
654165913	HTL00410	Chris	Jackson	541 Bank St, Overbrook, Ottawa, Ontario, Canada	Security
909175823	HTL00410	Alex	Brown	922 St. Laurent Blvd, Manotick, Ottawa, Ontario, Canada	Security
786712481	HTL00410	Charlotte	Jackson	616 McArthur Ave, Orleans, Ottawa, Ontario, Canada	Housekeeper
492241702	HTL00410	Sophia	Brown	988 Third St, Byward Market, Ottawa, Ontario, Canada	Receptionist
606065199	HTL00410	Olivia	Lopez	928 Main St, Kanata, Ottawa, Ontario, Canada	Manager
677922563	HTL00411	David	Taylor	524 Merivale Rd, Stittsville, Ottawa, Ontario, Canada	Receptionist
615080246	HTL00411	Charlotte	Rodriguez	650 Lisgar St, Kanata, Ottawa, Ontario, Canada	Security
913030898	HTL00411	Alex	Smith	671 Carling Ave, Cumberland, Ottawa, Ontario, Canada	Receptionist
615174205	HTL00411	Jane	Gonzalez	150 McArthur Ave, Centretown, Ottawa, Ontario, Canada	Receptionist
503883924	HTL00411	Jane	Miller	930 Fourth St, Cumberland, Ottawa, Ontario, Canada	Security
129893306	HTL00411	Emily	Wilson	255 St. Laurent Blvd, New Edinburgh, Ottawa, Ontario, Canada	Manager
524795486	HTL00412	Katie	Johnson	780 Somerset St, Alta Vista, Ottawa, Ontario, Canada	Housekeeper
191282544	HTL00412	John	Jackson	442 Bank St, Alta Vista, Ottawa, Ontario, Canada	Chef
470099287	HTL00412	Olivia	Jackson	655 Bank St, Nepean, Ottawa, Ontario, Canada	Receptionist
985277113	HTL00412	Laura	Garcia	807 Fourth St, Barrhaven, Ottawa, Ontario, Canada	Receptionist
317417145	HTL00412	Megan	Martinez	857 Elgin St, Orleans, Ottawa, Ontario, Canada	Manager
975977353	HTL00413	Olivia	Thomas	129 Second St, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
786888506	HTL00413	Jane	Martin	122 Merivale Rd, Sandy Hill, Ottawa, Ontario, Canada	Security
736120307	HTL00413	Grace	Miller	200 Lisgar St, Overbrook, Ottawa, Ontario, Canada	Security
134847894	HTL00413	Charlotte	Martinez	717 Bank St, Centretown, Ottawa, Ontario, Canada	Security
603443095	HTL00413	William	Miller	485 Somerset St, Sandy Hill, Ottawa, Ontario, Canada	Security
369696997	HTL00413	Laura	Taylor	529 Hunt Club Rd, Little Italy, Ottawa, Ontario, Canada	Security
838780403	HTL00413	Ethan	White	722 Third St, Westboro, Ottawa, Ontario, Canada	Manager
671766140	HTL00414	Grace	Johnson	288 Hunt Club Rd, Overbrook, Ottawa, Ontario, Canada	Chef
889347105	HTL00414	Sarah	Davis	283 Clyde Ave, Carleton Heights, Ottawa, Ontario, Canada	Chef
721782713	HTL00414	Olivia	Anderson	735 Somerset St, Little Italy, Ottawa, Ontario, Canada	Chef
666213613	HTL00414	Katie	Brown	546 McArthur Ave, Little Italy, Ottawa, Ontario, Canada	Receptionist
220477223	HTL00414	Alex	Wilson	946 Catherine St, Alta Vista, Ottawa, Ontario, Canada	Security
196269948	HTL00414	Grace	Thomas	575 Main St, New Edinburgh, Ottawa, Ontario, Canada	Manager
349306933	HTL00415	Michael	White	993 Carling Ave, Little Italy, Ottawa, Ontario, Canada	Receptionist
123768465	HTL00415	Laura	Miller	766 Carling Ave, Westboro, Ottawa, Ontario, Canada	Housekeeper
561762110	HTL00415	Ethan	Anderson	651 Catherine St, Overbrook, Ottawa, Ontario, Canada	Chef
435411395	HTL00415	James	Hernandez	896 Clyde Ave, New Edinburgh, Ottawa, Ontario, Canada	Receptionist
120058050	HTL00415	Sarah	Garcia	368 Queen St, Old Ottawa East, Ottawa, Ontario, Canada	Manager
287951190	HTL00416	Sophia	Johnson	630 King St, Kanata, Ottawa, Ontario, Canada	Housekeeper
828883551	HTL00416	Charlotte	Rodriguez	360 Clyde Ave, Alta Vista, Ottawa, Ontario, Canada	Chef
591636657	HTL00416	Katie	Martin	495 Fourth St, Sandy Hill, Ottawa, Ontario, Canada	Housekeeper
728141278	HTL00416	Robert	Moore	865 Colonel By Dr, Old Ottawa East, Ottawa, Ontario, Canada	Security
437509532	HTL00416	John	Miller	614 Catherine St, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
990594217	HTL00416	Emily	Moore	415 Laurier Ave, Byward Market, Ottawa, Ontario, Canada	Manager
515801923	HTL00417	Charlotte	Hernandez	634 Bronson Ave, Old Ottawa East, Ottawa, Ontario, Canada	Chef
965474191	HTL00417	Katie	Smith	763 Rideau St, Nepean, Ottawa, Ontario, Canada	Security
328232385	HTL00417	Katie	Miller	376 Merivale Rd, Byward Market, Ottawa, Ontario, Canada	Security
514675625	HTL00417	Laura	Wilson	314 Bank St, Carp, Ottawa, Ontario, Canada	Chef
888694901	HTL00417	Ethan	Gonzalez	568 Gladstone Ave, Little Italy, Ottawa, Ontario, Canada	Receptionist
306299670	HTL00417	Emily	Martinez	542 Queen St, Carp, Ottawa, Ontario, Canada	Receptionist
800781738	HTL00417	John	Rodriguez	201 Lisgar St, Centretown, Ottawa, Ontario, Canada	Manager
800423601	HTL00418	Charlotte	Martin	433 Fourth St, Old Ottawa East, Ottawa, Ontario, Canada	Chef
531520277	HTL00418	Robert	Hernandez	945 Bronson Ave, Overbrook, Ottawa, Ontario, Canada	Security
993522341	HTL00418	Daniel	Davis	321 Main St, Little Italy, Ottawa, Ontario, Canada	Chef
680762919	HTL00418	Alex	Johnson	267 Carling Ave, Centretown, Ottawa, Ontario, Canada	Receptionist
341222711	HTL00418	Laura	Gonzalez	754 Gladstone Ave, The Glebe, Ottawa, Ontario, Canada	Security
531199834	HTL00418	Katie	White	757 Gladstone Ave, Stittsville, Ottawa, Ontario, Canada	Manager
678430769	HTL00419	David	Moore	532 King St, Byward Market, Ottawa, Ontario, Canada	Receptionist
406620495	HTL00419	Ethan	Taylor	998 Catherine St, Nepean, Ottawa, Ontario, Canada	Chef
439450683	HTL00419	Megan	Jackson	608 Laurier Ave, Centretown, Ottawa, Ontario, Canada	Housekeeper
438809179	HTL00419	Alex	Miller	963 Catherine St, Byward Market, Ottawa, Ontario, Canada	Housekeeper
375847615	HTL00419	Charlotte	Moore	634 Carling Ave, Manotick, Ottawa, Ontario, Canada	Housekeeper
216635703	HTL00419	David	Smith	245 Lisgar St, Sandy Hill, Ottawa, Ontario, Canada	Manager
246956987	HTL00500	Sophia	Garcia	434 Elgin St, The Glebe, Ottawa, Ontario, Canada	Receptionist
928240219	HTL00500	Daniel	Davis	944 Colonel By Dr, Stittsville, Ottawa, Ontario, Canada	Receptionist
367235484	HTL00500	John	Jackson	557 Isabella St, Stittsville, Ottawa, Ontario, Canada	Housekeeper
528228639	HTL00500	Megan	Johnson	339 Lisgar St, Cumberland, Ottawa, Ontario, Canada	Security
622513753	HTL00500	Sophia	Miller	861 Laurier Ave, Stittsville, Ottawa, Ontario, Canada	Security
782523833	HTL00500	Sophia	Anderson	236 Clyde Ave, Sandy Hill, Ottawa, Ontario, Canada	Manager
629911565	HTL00501	John	Jones	776 Isabella St, Byward Market, Ottawa, Ontario, Canada	Housekeeper
521469351	HTL00501	Chris	Jackson	500 Wellington St, New Edinburgh, Ottawa, Ontario, Canada	Security
117504847	HTL00501	James	Jones	383 Gladstone Ave, Nepean, Ottawa, Ontario, Canada	Security
499144545	HTL00501	Chris	Johnson	505 Queen St, Kanata, Ottawa, Ontario, Canada	Housekeeper
132160347	HTL00501	James	Martin	787 Wellington St, Little Italy, Ottawa, Ontario, Canada	Chef
361896122	HTL00501	Daniel	Hernandez	942 McArthur Ave, Orleans, Ottawa, Ontario, Canada	Security
367696208	HTL00501	Daniel	Moore	453 Catherine St, Byward Market, Ottawa, Ontario, Canada	Manager
538112279	HTL00502	Charlotte	White	748 Carling Ave, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
997478035	HTL00502	Megan	Anderson	939 Elgin St, Overbrook, Ottawa, Ontario, Canada	Chef
183850409	HTL00502	John	Gonzalez	378 Merivale Rd, Westboro, Ottawa, Ontario, Canada	Security
672821302	HTL00502	Sarah	White	657 Isabella St, Barrhaven, Ottawa, Ontario, Canada	Housekeeper
665909861	HTL00502	Michael	Taylor	662 Main St, Overbrook, Ottawa, Ontario, Canada	Manager
862553381	HTL00503	Sarah	Martin	314 St. Laurent Blvd, Byward Market, Ottawa, Ontario, Canada	Chef
399708832	HTL00503	John	White	641 Isabella St, Manotick, Ottawa, Ontario, Canada	Receptionist
318176177	HTL00503	David	Jackson	532 Bank St, Manotick, Ottawa, Ontario, Canada	Housekeeper
754179488	HTL00503	Emily	Thomas	829 Somerset St, Orleans, Ottawa, Ontario, Canada	Receptionist
169483473	HTL00503	David	White	351 Wellington St, Alta Vista, Ottawa, Ontario, Canada	Manager
668635461	HTL00504	Emily	Williams	560 Rideau St, Stittsville, Ottawa, Ontario, Canada	Chef
516355463	HTL00504	David	Lopez	368 Colonel By Dr, Carp, Ottawa, Ontario, Canada	Chef
966516373	HTL00504	Laura	Johnson	832 Somerset St, Stittsville, Ottawa, Ontario, Canada	Security
460714755	HTL00504	James	Smith	863 Lisgar St, Kanata, Ottawa, Ontario, Canada	Housekeeper
691176498	HTL00504	Grace	Jones	579 Clyde Ave, Carleton Heights, Ottawa, Ontario, Canada	Chef
877307074	HTL00504	David	Garcia	341 Bronson Ave, Alta Vista, Ottawa, Ontario, Canada	Manager
466713900	HTL00505	Chris	Jones	351 Elgin St, Centretown, Ottawa, Ontario, Canada	Security
580131406	HTL00505	John	Miller	117 Bank St, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
867758992	HTL00505	John	Miller	173 St. Laurent Blvd, Carp, Ottawa, Ontario, Canada	Receptionist
830258833	HTL00505	Laura	White	240 Third St, Little Italy, Ottawa, Ontario, Canada	Chef
391936745	HTL00505	Katie	Moore	228 Queen St, The Glebe, Ottawa, Ontario, Canada	Manager
635449665	HTL00506	Chris	Hernandez	497 Fourth St, Cumberland, Ottawa, Ontario, Canada	Chef
518833717	HTL00506	Robert	Jones	961 Hunt Club Rd, Carleton Heights, Ottawa, Ontario, Canada	Housekeeper
593210542	HTL00506	William	Martin	674 Somerset St, Centretown, Ottawa, Ontario, Canada	Security
572738909	HTL00506	John	Jackson	130 McArthur Ave, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
705124665	HTL00506	Michael	Miller	587 Bank St, Cumberland, Ottawa, Ontario, Canada	Receptionist
765457215	HTL00506	William	Wilson	611 Catherine St, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
887389839	HTL00506	Chris	Garcia	405 Lisgar St, Nepean, Ottawa, Ontario, Canada	Manager
900034504	HTL00507	Daniel	Lopez	796 Carling Ave, Barrhaven, Ottawa, Ontario, Canada	Security
647265764	HTL00507	Robert	Martinez	893 Elgin St, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
783811054	HTL00507	Matthew	Johnson	975 Bank St, Stittsville, Ottawa, Ontario, Canada	Receptionist
246396240	HTL00507	Charlotte	Jackson	266 Third St, Rockcliffe Park, Ottawa, Ontario, Canada	Security
885843848	HTL00507	Alex	Lopez	726 Clyde Ave, Byward Market, Ottawa, Ontario, Canada	Security
695188321	HTL00507	Robert	Wilson	858 St. Laurent Blvd, Barrhaven, Ottawa, Ontario, Canada	Chef
273921852	HTL00507	David	Anderson	437 Elgin St, Sandy Hill, Ottawa, Ontario, Canada	Manager
128067756	HTL00508	Matthew	Gonzalez	237 Catherine St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
708077847	HTL00508	Grace	Rodriguez	298 Clyde Ave, Alta Vista, Ottawa, Ontario, Canada	Receptionist
260900099	HTL00508	Chris	Martinez	408 Hunt Club Rd, Alta Vista, Ottawa, Ontario, Canada	Housekeeper
195864711	HTL00508	Michael	Anderson	717 Laurier Ave, Stittsville, Ottawa, Ontario, Canada	Chef
233683270	HTL00508	Jane	Wilson	810 Colonel By Dr, Orleans, Ottawa, Ontario, Canada	Receptionist
260705996	HTL00508	John	Martin	982 Second St, Byward Market, Ottawa, Ontario, Canada	Manager
854196765	HTL00509	Katie	Jones	611 Lisgar St, Stittsville, Ottawa, Ontario, Canada	Housekeeper
973118104	HTL00509	Ethan	Jackson	268 Third St, Sandy Hill, Ottawa, Ontario, Canada	Receptionist
195743563	HTL00509	Laura	Williams	242 Fourth St, Old Ottawa East, Ottawa, Ontario, Canada	Receptionist
680351967	HTL00509	Megan	Garcia	569 Queen St, Westboro, Ottawa, Ontario, Canada	Security
841557780	HTL00509	Olivia	Johnson	115 Carling Ave, Manotick, Ottawa, Ontario, Canada	Security
169665458	HTL00509	William	Rodriguez	117 Gladstone Ave, Barrhaven, Ottawa, Ontario, Canada	Receptionist
268543793	HTL00509	Sophia	Martinez	996 King St, Old Ottawa East, Ottawa, Ontario, Canada	Manager
249346063	HTL00510	Laura	Davis	558 Gladstone Ave, Rockcliffe Park, Ottawa, Ontario, Canada	Security
438356042	HTL00510	David	Thomas	850 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	Receptionist
273665898	HTL00510	Alex	Taylor	683 Third St, Orleans, Ottawa, Ontario, Canada	Chef
845445790	HTL00510	Matthew	Wilson	940 Hunt Club Rd, Old Ottawa East, Ottawa, Ontario, Canada	Housekeeper
447717282	HTL00510	Emily	Smith	805 Laurier Ave, Cumberland, Ottawa, Ontario, Canada	Manager
999689807	HTL00511	Grace	Garcia	810 Catherine St, Overbrook, Ottawa, Ontario, Canada	Security
112280351	HTL00511	James	Martin	936 Gladstone Ave, Nepean, Ottawa, Ontario, Canada	Housekeeper
818163445	HTL00511	Michael	Moore	785 Main St, Stittsville, Ottawa, Ontario, Canada	Housekeeper
518871314	HTL00511	Laura	Anderson	451 Somerset St, Carleton Heights, Ottawa, Ontario, Canada	Receptionist
897510820	HTL00511	Robert	Johnson	726 Somerset St, Little Italy, Ottawa, Ontario, Canada	Manager
819587464	HTL00512	David	Miller	203 Isabella St, Rockcliffe Park, Ottawa, Ontario, Canada	Security
626589571	HTL00512	Charlotte	Jones	438 Clyde Ave, Westboro, Ottawa, Ontario, Canada	Security
637404737	HTL00512	Olivia	Davis	762 Clyde Ave, Overbrook, Ottawa, Ontario, Canada	Chef
341052260	HTL00512	Charlotte	White	886 Clyde Ave, Overbrook, Ottawa, Ontario, Canada	Security
254364253	HTL00512	Alex	Gonzalez	838 Queen St, Barrhaven, Ottawa, Ontario, Canada	Chef
247008549	HTL00512	John	Johnson	607 Wellington St, Nepean, Ottawa, Ontario, Canada	Housekeeper
503038350	HTL00512	Daniel	Davis	778 Hunt Club Rd, New Edinburgh, Ottawa, Ontario, Canada	Manager
895646063	HTL00513	Michael	Williams	772 Gladstone Ave, Carp, Ottawa, Ontario, Canada	Receptionist
369342135	HTL00513	Megan	Garcia	318 Hunt Club Rd, Little Italy, Ottawa, Ontario, Canada	Security
329222599	HTL00513	Olivia	Thomas	201 Third St, The Glebe, Ottawa, Ontario, Canada	Chef
573044405	HTL00513	James	Lopez	917 Merivale Rd, Carleton Heights, Ottawa, Ontario, Canada	Security
663073912	HTL00513	Megan	Taylor	588 King St, Centretown, Ottawa, Ontario, Canada	Receptionist
843041866	HTL00513	Emily	Jones	520 Elgin St, Overbrook, Ottawa, Ontario, Canada	Chef
378388761	HTL00513	Robert	Lopez	514 Somerset St, Manotick, Ottawa, Ontario, Canada	Manager
280288931	HTL00514	Grace	Hernandez	657 King St, Carleton Heights, Ottawa, Ontario, Canada	Security
388150058	HTL00514	Ethan	Rodriguez	134 Bank St, Cumberland, Ottawa, Ontario, Canada	Housekeeper
246127682	HTL00514	Matthew	Martin	235 Third St, Centretown, Ottawa, Ontario, Canada	Chef
605557125	HTL00514	Chris	Johnson	978 Main St, Barrhaven, Ottawa, Ontario, Canada	Chef
690002615	HTL00514	Matthew	Martin	932 Carling Ave, Carp, Ottawa, Ontario, Canada	Receptionist
661498712	HTL00514	Katie	Brown	326 Laurier Ave, Sandy Hill, Ottawa, Ontario, Canada	Chef
416317471	HTL00514	Daniel	Taylor	855 Bank St, Orleans, Ottawa, Ontario, Canada	Manager
\.


--
-- TOC entry 3763 (class 0 OID 16838)
-- Dependencies: 220
-- Data for Name: hotel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotel (hotel_id, chain_id, address, num_rooms, contact_email, star_category) FROM stdin;
HTL00100	CH001	291 Elgin St, Sandy Hill, Ottawa, Ontario, Canada	16	htl00100@hotelsworld.com	3
HTL00101	CH001	226 Hunt Club Rd, Kanata, Ottawa, Ontario, Canada	15	htl00101@hotelsworld.com	3
HTL00102	CH001	828 Wellington St, Carp, Ottawa, Ontario, Canada	15	htl00102@hotelsworld.com	4
HTL00103	CH001	402 Isabella St, Nepean, Ottawa, Ontario, Canada	14	htl00103@hotelsworld.com	4
HTL00104	CH001	246 Second St, Centretown, Ottawa, Ontario, Canada	16	htl00104@hotelsworld.com	5
HTL00105	CH001	784 Gladstone Ave, Sandy Hill, Ottawa, Ontario, Canada	18	htl00105@hotelsworld.com	4
HTL00106	CH001	545 Bronson Ave, Old Ottawa East, Ottawa, Ontario, Canada	11	htl00106@hotelsworld.com	5
HTL00107	CH001	859 Catherine St, Carp, Ottawa, Ontario, Canada	16	htl00107@hotelsworld.com	1
HTL00108	CH001	343 Hunt Club Rd, Kanata, Ottawa, Ontario, Canada	16	htl00108@hotelsworld.com	5
HTL00109	CH001	978 Rideau St, Carp, Ottawa, Ontario, Canada	12	htl00109@hotelsworld.com	5
HTL00110	CH001	320 Carling Ave, Alta Vista, Ottawa, Ontario, Canada	18	htl00110@hotelsworld.com	3
HTL00111	CH001	948 Colonel By Dr, Old Ottawa East, Ottawa, Ontario, Canada	16	htl00111@hotelsworld.com	3
HTL00112	CH001	435 Rideau St, Rockcliffe Park, Ottawa, Ontario, Canada	18	htl00112@hotelsworld.com	4
HTL00113	CH001	652 Wellington St, Stittsville, Ottawa, Ontario, Canada	16	htl00113@hotelsworld.com	4
HTL00114	CH001	832 Queen St, Centretown, Ottawa, Ontario, Canada	13	htl00114@hotelsworld.com	3
HTL00115	CH001	361 Second St, Overbrook, Ottawa, Ontario, Canada	18	htl00115@hotelsworld.com	2
HTL00116	CH001	926 King St, Barrhaven, Ottawa, Ontario, Canada	18	htl00116@hotelsworld.com	2
HTL00117	CH001	433 McArthur Ave, Old Ottawa East, Ottawa, Ontario, Canada	15	htl00117@hotelsworld.com	4
HTL00118	CH001	267 Lisgar St, The Glebe, Ottawa, Ontario, Canada	12	htl00118@hotelsworld.com	4
HTL00119	CH001	850 Wellington St, Westboro, Ottawa, Ontario, Canada	11	htl00119@hotelsworld.com	3
HTL00120	CH001	164 Colonel By Dr, Nepean, Ottawa, Ontario, Canada	12	htl00120@hotelsworld.com	1
HTL00121	CH001	482 Wellington St, Carleton Heights, Ottawa, Ontario, Canada	13	htl00121@hotelsworld.com	3
HTL00122	CH001	220 Catherine St, Cumberland, Ottawa, Ontario, Canada	17	htl00122@hotelsworld.com	1
HTL00200	CH002	810 Bank St, Sandy Hill, Ottawa, Ontario, Canada	10	htl00200@hotelsworld.com	4
HTL00201	CH002	793 Second St, Sandy Hill, Ottawa, Ontario, Canada	19	htl00201@hotelsworld.com	1
HTL00202	CH002	333 Rideau St, Old Ottawa East, Ottawa, Ontario, Canada	17	htl00202@hotelsworld.com	5
HTL00203	CH002	267 Laurier Ave, Overbrook, Ottawa, Ontario, Canada	18	htl00203@hotelsworld.com	4
HTL00204	CH002	530 Catherine St, Barrhaven, Ottawa, Ontario, Canada	12	htl00204@hotelsworld.com	4
HTL00205	CH002	907 Catherine St, New Edinburgh, Ottawa, Ontario, Canada	15	htl00205@hotelsworld.com	4
HTL00206	CH002	111 Lisgar St, Cumberland, Ottawa, Ontario, Canada	14	htl00206@hotelsworld.com	1
HTL00207	CH002	740 St. Laurent Blvd, Stittsville, Ottawa, Ontario, Canada	14	htl00207@hotelsworld.com	5
HTL00208	CH002	388 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	19	htl00208@hotelsworld.com	2
HTL00209	CH002	300 Somerset St, Little Italy, Ottawa, Ontario, Canada	12	htl00209@hotelsworld.com	4
HTL00210	CH002	117 Hunt Club Rd, Nepean, Ottawa, Ontario, Canada	14	htl00210@hotelsworld.com	2
HTL00211	CH002	889 King St, Rockcliffe Park, Ottawa, Ontario, Canada	19	htl00211@hotelsworld.com	4
HTL00212	CH002	511 Bank St, Manotick, Ottawa, Ontario, Canada	18	htl00212@hotelsworld.com	1
HTL00213	CH002	746 Colonel By Dr, Alta Vista, Ottawa, Ontario, Canada	10	htl00213@hotelsworld.com	4
HTL00214	CH002	573 McArthur Ave, Byward Market, Ottawa, Ontario, Canada	12	htl00214@hotelsworld.com	1
HTL00215	CH002	911 Second St, Barrhaven, Ottawa, Ontario, Canada	13	htl00215@hotelsworld.com	2
HTL00216	CH002	850 Elgin St, Old Ottawa East, Ottawa, Ontario, Canada	13	htl00216@hotelsworld.com	2
HTL00217	CH002	743 Laurier Ave, Stittsville, Ottawa, Ontario, Canada	14	htl00217@hotelsworld.com	4
HTL00300	CH003	685 Second St, Overbrook, Ottawa, Ontario, Canada	18	htl00300@hotelsworld.com	2
HTL00301	CH003	571 Carling Ave, Westboro, Ottawa, Ontario, Canada	16	htl00301@hotelsworld.com	2
HTL00302	CH003	247 Bank St, Overbrook, Ottawa, Ontario, Canada	11	htl00302@hotelsworld.com	1
HTL00303	CH003	295 Lisgar St, Westboro, Ottawa, Ontario, Canada	14	htl00303@hotelsworld.com	1
HTL00304	CH003	486 Elgin St, Barrhaven, Ottawa, Ontario, Canada	14	htl00304@hotelsworld.com	4
HTL00305	CH003	501 Colonel By Dr, Westboro, Ottawa, Ontario, Canada	14	htl00305@hotelsworld.com	5
HTL00306	CH003	928 Third St, Centretown, Ottawa, Ontario, Canada	11	htl00306@hotelsworld.com	3
HTL00307	CH003	988 Second St, Alta Vista, Ottawa, Ontario, Canada	17	htl00307@hotelsworld.com	4
HTL00308	CH003	520 Somerset St, Manotick, Ottawa, Ontario, Canada	16	htl00308@hotelsworld.com	3
HTL00309	CH003	139 Bank St, New Edinburgh, Ottawa, Ontario, Canada	10	htl00309@hotelsworld.com	1
HTL00310	CH003	383 Clyde Ave, Cumberland, Ottawa, Ontario, Canada	17	htl00310@hotelsworld.com	4
HTL00311	CH003	836 Rideau St, Overbrook, Ottawa, Ontario, Canada	19	htl00311@hotelsworld.com	5
HTL00312	CH003	727 McArthur Ave, Little Italy, Ottawa, Ontario, Canada	17	htl00312@hotelsworld.com	3
HTL00313	CH003	479 Carling Ave, The Glebe, Ottawa, Ontario, Canada	13	htl00313@hotelsworld.com	1
HTL00314	CH003	426 Wellington St, Byward Market, Ottawa, Ontario, Canada	16	htl00314@hotelsworld.com	3
HTL00315	CH003	396 Laurier Ave, Cumberland, Ottawa, Ontario, Canada	15	htl00315@hotelsworld.com	2
HTL00400	CH004	586 Wellington St, Old Ottawa East, Ottawa, Ontario, Canada	10	htl00400@hotelsworld.com	3
HTL00401	CH004	899 Laurier Ave, Orleans, Ottawa, Ontario, Canada	16	htl00401@hotelsworld.com	5
HTL00402	CH004	735 Third St, Carleton Heights, Ottawa, Ontario, Canada	11	htl00402@hotelsworld.com	1
HTL00403	CH004	763 Merivale Rd, Carp, Ottawa, Ontario, Canada	12	htl00403@hotelsworld.com	1
HTL00404	CH004	751 Rideau St, Byward Market, Ottawa, Ontario, Canada	17	htl00404@hotelsworld.com	2
HTL00405	CH004	478 Clyde Ave, Carleton Heights, Ottawa, Ontario, Canada	17	htl00405@hotelsworld.com	5
HTL00406	CH004	355 Queen St, Sandy Hill, Ottawa, Ontario, Canada	16	htl00406@hotelsworld.com	5
HTL00407	CH004	988 Second St, Carp, Ottawa, Ontario, Canada	15	htl00407@hotelsworld.com	4
HTL00408	CH004	656 St. Laurent Blvd, Orleans, Ottawa, Ontario, Canada	12	htl00408@hotelsworld.com	3
HTL00409	CH004	942 Bronson Ave, Old Ottawa East, Ottawa, Ontario, Canada	11	htl00409@hotelsworld.com	3
HTL00410	CH004	282 Merivale Rd, Old Ottawa East, Ottawa, Ontario, Canada	15	htl00410@hotelsworld.com	3
HTL00411	CH004	900 Bank St, Stittsville, Ottawa, Ontario, Canada	15	htl00411@hotelsworld.com	5
HTL00412	CH004	997 Queen St, Manotick, Ottawa, Ontario, Canada	10	htl00412@hotelsworld.com	2
HTL00413	CH004	630 Carling Ave, New Edinburgh, Ottawa, Ontario, Canada	16	htl00413@hotelsworld.com	3
HTL00414	CH004	699 Gladstone Ave, Westboro, Ottawa, Ontario, Canada	10	htl00414@hotelsworld.com	4
HTL00415	CH004	257 Somerset St, Nepean, Ottawa, Ontario, Canada	12	htl00415@hotelsworld.com	2
HTL00416	CH004	306 Fourth St, Old Ottawa East, Ottawa, Ontario, Canada	19	htl00416@hotelsworld.com	2
HTL00417	CH004	727 Queen St, Little Italy, Ottawa, Ontario, Canada	20	htl00417@hotelsworld.com	5
HTL00418	CH004	824 Main St, Carp, Ottawa, Ontario, Canada	18	htl00418@hotelsworld.com	1
HTL00419	CH004	738 St. Laurent Blvd, Byward Market, Ottawa, Ontario, Canada	18	htl00419@hotelsworld.com	2
HTL00500	CH005	416 Hunt Club Rd, The Glebe, Ottawa, Ontario, Canada	14	htl00500@hotelsworld.com	3
HTL00501	CH005	782 Hunt Club Rd, Barrhaven, Ottawa, Ontario, Canada	18	htl00501@hotelsworld.com	3
HTL00502	CH005	872 Rideau St, Carleton Heights, Ottawa, Ontario, Canada	11	htl00502@hotelsworld.com	1
HTL00503	CH005	606 Merivale Rd, Alta Vista, Ottawa, Ontario, Canada	13	htl00503@hotelsworld.com	1
HTL00504	CH005	797 St. Laurent Blvd, Stittsville, Ottawa, Ontario, Canada	14	htl00504@hotelsworld.com	3
HTL00505	CH005	196 McArthur Ave, Carp, Ottawa, Ontario, Canada	10	htl00505@hotelsworld.com	4
HTL00506	CH005	422 Rideau St, Byward Market, Ottawa, Ontario, Canada	15	htl00506@hotelsworld.com	4
HTL00507	CH005	155 Laurier Ave, Carleton Heights, Ottawa, Ontario, Canada	19	htl00507@hotelsworld.com	2
HTL00508	CH005	448 Clyde Ave, Kanata, Ottawa, Ontario, Canada	18	htl00508@hotelsworld.com	3
HTL00509	CH005	251 Hunt Club Rd, Stittsville, Ottawa, Ontario, Canada	19	htl00509@hotelsworld.com	2
HTL00510	CH005	264 Queen St, Centretown, Ottawa, Ontario, Canada	16	htl00510@hotelsworld.com	4
HTL00511	CH005	479 Rideau St, Nepean, Ottawa, Ontario, Canada	12	htl00511@hotelsworld.com	2
HTL00512	CH005	791 Colonel By Dr, The Glebe, Ottawa, Ontario, Canada	16	htl00512@hotelsworld.com	4
HTL00513	CH005	564 Merivale Rd, Carp, Ottawa, Ontario, Canada	11	htl00513@hotelsworld.com	2
HTL00514	CH005	652 Isabella St, Sandy Hill, Ottawa, Ontario, Canada	16	htl00514@hotelsworld.com	5
\.


--
-- TOC entry 3760 (class 0 OID 16809)
-- Dependencies: 217
-- Data for Name: hotelchain; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotelchain (chain_id, num_hotels, central_office_address) FROM stdin;
CH001	23	496 Carling Ave, Carleton Heights, Ottawa, Ontario, Canada
CH002	18	810 Main St, New Edinburgh, Ottawa, Ontario, Canada
CH003	16	955 Fourth St, Manotick, Ottawa, Ontario, Canada
CH004	20	112 Queen St, Barrhaven, Ottawa, Ontario, Canada
CH005	15	464 Isabella St, Cumberland, Ottawa, Ontario, Canada
\.


--
-- TOC entry 3764 (class 0 OID 16852)
-- Dependencies: 221
-- Data for Name: hotelphonenumber; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotelphonenumber (hotel_id, phone_number) FROM stdin;
HTL00100	+1-647-340-4381
HTL00101	+1-416-709-7952
HTL00102	+1-437-294-6041
HTL00103	+1-613-200-4081
HTL00104	+1-905-942-7930
HTL00105	+1-226-690-6689
HTL00106	+1-519-520-2049
HTL00107	+1-905-647-5040
HTL00108	+1-905-601-2826
HTL00109	+1-289-439-7639
HTL00110	+1-905-458-7754
HTL00111	+1-905-497-4751
HTL00112	+1-437-775-1295
HTL00113	+1-647-636-9642
HTL00114	+1-437-754-5611
HTL00115	+1-416-522-5000
HTL00116	+1-905-821-1413
HTL00117	+1-647-148-9744
HTL00118	+1-519-166-6620
HTL00119	+1-226-814-9674
HTL00120	+1-613-636-5863
HTL00121	+1-905-880-3490
HTL00122	+1-226-185-5995
HTL00200	+1-905-136-5717
HTL00201	+1-519-904-3464
HTL00202	+1-289-437-2808
HTL00203	+1-705-197-2842
HTL00204	+1-416-214-5059
HTL00205	+1-416-104-9196
HTL00206	+1-905-647-8173
HTL00207	+1-437-829-5654
HTL00208	+1-905-649-5606
HTL00209	+1-705-763-9534
HTL00210	+1-647-226-3043
HTL00211	+1-289-817-2963
HTL00212	+1-647-476-6308
HTL00213	+1-437-119-4256
HTL00214	+1-905-569-2642
HTL00215	+1-613-467-5992
HTL00216	+1-613-183-7102
HTL00217	+1-289-666-9970
HTL00300	+1-519-879-2542
HTL00301	+1-519-166-2018
HTL00302	+1-226-526-2193
HTL00303	+1-437-575-5842
HTL00304	+1-226-319-3207
HTL00305	+1-519-218-7587
HTL00306	+1-289-316-6022
HTL00307	+1-289-651-5914
HTL00308	+1-226-934-9680
HTL00309	+1-416-377-8720
HTL00310	+1-613-681-1366
HTL00311	+1-613-455-1168
HTL00312	+1-905-928-9159
HTL00313	+1-519-780-9896
HTL00314	+1-289-608-6967
HTL00315	+1-705-763-6176
HTL00400	+1-905-855-6865
HTL00401	+1-905-906-7301
HTL00402	+1-437-806-3073
HTL00403	+1-905-918-7147
HTL00404	+1-437-965-8514
HTL00405	+1-705-656-1879
HTL00406	+1-289-399-1940
HTL00407	+1-519-992-1117
HTL00408	+1-905-275-7726
HTL00409	+1-905-575-4742
HTL00410	+1-647-166-6065
HTL00411	+1-416-509-2530
HTL00412	+1-705-514-1237
HTL00413	+1-416-297-4443
HTL00414	+1-647-912-6454
HTL00415	+1-905-886-3531
HTL00416	+1-905-225-2953
HTL00417	+1-705-647-7954
HTL00418	+1-705-873-9466
HTL00419	+1-705-294-9844
HTL00500	+1-613-489-9993
HTL00501	+1-226-661-8792
HTL00502	+1-226-404-8747
HTL00503	+1-519-174-3058
HTL00504	+1-416-787-2705
HTL00505	+1-519-103-1502
HTL00506	+1-613-385-8666
HTL00507	+1-613-139-9899
HTL00508	+1-905-699-4803
HTL00509	+1-705-511-8397
HTL00510	+1-289-683-4999
HTL00511	+1-416-455-5385
HTL00512	+1-519-852-3105
HTL00513	+1-289-631-1832
HTL00514	+1-437-654-4301
\.


--
-- TOC entry 3766 (class 0 OID 16874)
-- Dependencies: 223
-- Data for Name: manages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.manages (ssn, hotel_id) FROM stdin;
862006326	HTL00100
900318961	HTL00101
571040175	HTL00102
359925368	HTL00103
933002441	HTL00104
949257555	HTL00105
781107245	HTL00106
684318041	HTL00107
789586452	HTL00108
301768079	HTL00109
793120402	HTL00110
600085755	HTL00111
600613133	HTL00112
750967930	HTL00113
802512466	HTL00114
487987034	HTL00115
907947484	HTL00116
264578664	HTL00117
328228713	HTL00118
492210621	HTL00119
636336321	HTL00120
104215231	HTL00121
489034233	HTL00122
263708702	HTL00200
570618242	HTL00201
587627136	HTL00202
660692144	HTL00203
565627182	HTL00204
173606766	HTL00205
655964054	HTL00206
754161075	HTL00207
709796852	HTL00208
515283781	HTL00209
589219180	HTL00210
529845936	HTL00211
463564949	HTL00212
729603236	HTL00213
932068025	HTL00214
542855157	HTL00215
339184595	HTL00216
101026982	HTL00217
762283861	HTL00300
826649731	HTL00301
496599344	HTL00302
381387349	HTL00303
450231252	HTL00304
273152270	HTL00305
815991791	HTL00306
501075427	HTL00307
565681002	HTL00308
653122064	HTL00309
300107250	HTL00310
384679756	HTL00311
339209877	HTL00312
569612023	HTL00313
825492311	HTL00314
757184903	HTL00315
399164135	HTL00400
436069321	HTL00401
167109071	HTL00402
984619503	HTL00403
602741569	HTL00404
596703188	HTL00405
658996615	HTL00406
848141446	HTL00407
704669251	HTL00408
144159414	HTL00409
606065199	HTL00410
129893306	HTL00411
317417145	HTL00412
838780403	HTL00413
196269948	HTL00414
120058050	HTL00415
990594217	HTL00416
800781738	HTL00417
531199834	HTL00418
216635703	HTL00419
782523833	HTL00500
367696208	HTL00501
665909861	HTL00502
169483473	HTL00503
877307074	HTL00504
391936745	HTL00505
887389839	HTL00506
273921852	HTL00507
260705996	HTL00508
268543793	HTL00509
447717282	HTL00510
897510820	HTL00511
503038350	HTL00512
378388761	HTL00513
416317471	HTL00514
\.


--
-- TOC entry 3772 (class 0 OID 16942)
-- Dependencies: 229
-- Data for Name: rental; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rental (rental_id, customer_id, check_in_date, check_out_date, room_id) FROM stdin;
\.


--
-- TOC entry 3774 (class 0 OID 16973)
-- Dependencies: 231
-- Data for Name: rents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rents (ssn, customer_id, room_id) FROM stdin;
\.


--
-- TOC entry 3767 (class 0 OID 16889)
-- Dependencies: 224
-- Data for Name: room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.room (room_id, hotel_id, price, capacity, view, extendable, status) FROM stdin;
RM0010102 	HTL00101	406.77	SUITE	Pool View	t	Unavailable
RM0010000 	HTL00100	403.33	TRIPLE	Lake View	t	Unavailable
RM0010001 	HTL00100	234.01	DOUBLE	Mountain View	t	Available
RM0010002 	HTL00100	165.96	DOUBLE	Garden View	f	Available
RM0010003 	HTL00100	212.08	SUITE	Forest View	t	Available
RM0010004 	HTL00100	222.38	SINGLE	Garden View	f	Available
RM0010005 	HTL00100	325.95	QUAD	Courtyard View	t	Available
RM0010006 	HTL00100	113.93	DOUBLE	Mountain View	t	Available
RM0010007 	HTL00100	245.60	SINGLE	Mountain View	f	Available
RM0010008 	HTL00100	311.14	SINGLE	Courtyard View	f	Available
RM0010009 	HTL00100	135.73	DOUBLE	Forest View	f	Available
RM0010010 	HTL00100	174.20	TRIPLE	Courtyard View	t	Available
RM0010011 	HTL00100	445.56	DOUBLE	Garden View	t	Available
RM0010012 	HTL00100	457.01	SUITE	City View	t	Available
RM0010013 	HTL00100	499.63	QUAD	Mountain View	t	Available
RM0010014 	HTL00100	203.47	SINGLE	River View	f	Available
RM0010015 	HTL00100	321.70	QUAD	Mountain View	t	Available
RM0010100 	HTL00101	475.81	QUAD	Courtyard View	f	Available
RM0010101 	HTL00101	253.77	SINGLE	Forest View	t	Available
RM0010103 	HTL00101	300.73	TRIPLE	Garden View	t	Available
RM0010104 	HTL00101	324.69	DOUBLE	Lake View	t	Available
RM0010105 	HTL00101	435.63	QUAD	Forest View	t	Available
RM0010106 	HTL00101	437.01	SUITE	Sea View	t	Available
RM0010107 	HTL00101	103.41	SINGLE	Sea View	f	Available
RM0010108 	HTL00101	451.47	SINGLE	Courtyard View	t	Available
RM0010109 	HTL00101	133.90	SINGLE	Garden View	f	Available
RM0010110 	HTL00101	366.23	QUAD	Garden View	f	Available
RM0010111 	HTL00101	407.84	DOUBLE	City View	t	Available
RM0010112 	HTL00101	408.84	SINGLE	City View	t	Available
RM0010113 	HTL00101	263.91	DOUBLE	Pool View	t	Available
RM0010114 	HTL00101	322.72	TRIPLE	River View	f	Available
RM0010200 	HTL00102	267.59	DOUBLE	Sea View	t	Available
RM0010201 	HTL00102	480.48	TRIPLE	Pool View	f	Available
RM0010202 	HTL00102	134.31	QUAD	Forest View	f	Available
RM0010203 	HTL00102	225.49	TRIPLE	City View	t	Available
RM0010204 	HTL00102	437.73	TRIPLE	Forest View	f	Available
RM0010205 	HTL00102	359.58	TRIPLE	Pool View	f	Available
RM0010206 	HTL00102	482.47	SUITE	Lake View	f	Available
RM0010207 	HTL00102	391.20	QUAD	River View	f	Available
RM0010208 	HTL00102	381.92	TRIPLE	Courtyard View	f	Available
RM0010209 	HTL00102	222.84	SUITE	Pool View	f	Available
RM0010210 	HTL00102	185.92	SINGLE	Courtyard View	t	Available
RM0010211 	HTL00102	363.71	TRIPLE	Pool View	f	Available
RM0010212 	HTL00102	114.28	SINGLE	Pool View	t	Available
RM0010213 	HTL00102	250.68	QUAD	Mountain View	f	Available
RM0010214 	HTL00102	456.97	QUAD	Lake View	f	Available
RM0010300 	HTL00103	257.20	SUITE	Lake View	f	Available
RM0010301 	HTL00103	125.03	SINGLE	River View	f	Available
RM0010302 	HTL00103	457.92	TRIPLE	Garden View	t	Available
RM0010303 	HTL00103	121.75	SUITE	Lake View	f	Available
RM0010304 	HTL00103	395.09	SUITE	Forest View	f	Available
RM0010305 	HTL00103	198.09	QUAD	Mountain View	t	Available
RM0010306 	HTL00103	353.42	DOUBLE	Skyline View	f	Available
RM0010307 	HTL00103	280.32	TRIPLE	Garden View	f	Available
RM0010308 	HTL00103	487.25	SUITE	Skyline View	t	Available
RM0010309 	HTL00103	280.57	SINGLE	Mountain View	f	Available
RM0010310 	HTL00103	307.03	SUITE	City View	f	Available
RM0010311 	HTL00103	193.35	SINGLE	Mountain View	t	Available
RM0010312 	HTL00103	269.71	SUITE	River View	t	Available
RM0010313 	HTL00103	235.98	DOUBLE	Mountain View	f	Available
RM0010400 	HTL00104	232.88	SINGLE	River View	t	Available
RM0010401 	HTL00104	475.53	TRIPLE	Skyline View	t	Available
RM0010402 	HTL00104	396.82	QUAD	Sea View	f	Available
RM0010403 	HTL00104	164.44	SINGLE	Lake View	t	Available
RM0010404 	HTL00104	220.94	DOUBLE	City View	f	Available
RM0010405 	HTL00104	204.14	DOUBLE	Garden View	f	Available
RM0010406 	HTL00104	104.73	TRIPLE	Forest View	f	Available
RM0010407 	HTL00104	464.42	SINGLE	Courtyard View	f	Available
RM0010408 	HTL00104	126.01	DOUBLE	Skyline View	f	Available
RM0010409 	HTL00104	276.08	DOUBLE	Pool View	f	Available
RM0010410 	HTL00104	127.09	DOUBLE	River View	t	Available
RM0010411 	HTL00104	188.41	DOUBLE	Sea View	t	Available
RM0010412 	HTL00104	356.33	TRIPLE	Mountain View	f	Available
RM0010413 	HTL00104	315.59	DOUBLE	Mountain View	t	Available
RM0010414 	HTL00104	479.09	SUITE	Forest View	f	Available
RM0010415 	HTL00104	357.02	SUITE	Forest View	f	Available
RM0010500 	HTL00105	285.35	TRIPLE	Mountain View	f	Available
RM0010501 	HTL00105	457.84	TRIPLE	Mountain View	t	Available
RM0010502 	HTL00105	137.60	TRIPLE	Forest View	t	Available
RM0010503 	HTL00105	136.31	SINGLE	Garden View	t	Available
RM0010504 	HTL00105	405.73	QUAD	Pool View	f	Available
RM0010505 	HTL00105	429.04	SUITE	Skyline View	f	Available
RM0010506 	HTL00105	441.77	DOUBLE	Courtyard View	f	Available
RM0010507 	HTL00105	443.77	QUAD	Sea View	f	Available
RM0010508 	HTL00105	317.80	DOUBLE	River View	f	Available
RM0010509 	HTL00105	132.02	TRIPLE	Lake View	t	Available
RM0010510 	HTL00105	372.41	DOUBLE	Skyline View	f	Available
RM0010511 	HTL00105	267.69	TRIPLE	Pool View	f	Available
RM0010512 	HTL00105	428.77	TRIPLE	Sea View	f	Available
RM0010513 	HTL00105	387.50	QUAD	River View	f	Available
RM0010514 	HTL00105	102.73	QUAD	Garden View	f	Available
RM0010515 	HTL00105	338.30	SINGLE	Sea View	t	Available
RM0010516 	HTL00105	458.92	SINGLE	Courtyard View	t	Available
RM0010517 	HTL00105	356.94	DOUBLE	Lake View	t	Available
RM0010600 	HTL00106	371.82	SUITE	Garden View	t	Available
RM0010601 	HTL00106	389.56	QUAD	City View	t	Available
RM0010602 	HTL00106	274.41	SUITE	Pool View	f	Available
RM0010603 	HTL00106	279.70	QUAD	Sea View	t	Available
RM0010604 	HTL00106	149.91	SINGLE	Pool View	f	Available
RM0010605 	HTL00106	477.96	SINGLE	Garden View	t	Available
RM0010606 	HTL00106	448.47	SUITE	Pool View	t	Available
RM0010607 	HTL00106	218.81	SUITE	Skyline View	f	Available
RM0010608 	HTL00106	292.42	DOUBLE	Lake View	t	Available
RM0010609 	HTL00106	381.82	SINGLE	Skyline View	t	Available
RM0010610 	HTL00106	407.84	QUAD	Garden View	t	Available
RM0010700 	HTL00107	249.61	QUAD	Courtyard View	t	Available
RM0010701 	HTL00107	166.01	DOUBLE	City View	t	Available
RM0010702 	HTL00107	302.31	SUITE	Mountain View	f	Available
RM0010703 	HTL00107	276.18	TRIPLE	Skyline View	f	Available
RM0010704 	HTL00107	374.25	TRIPLE	Forest View	t	Available
RM0010705 	HTL00107	406.34	DOUBLE	Mountain View	f	Available
RM0010706 	HTL00107	395.43	SUITE	Sea View	t	Available
RM0010707 	HTL00107	206.68	DOUBLE	Lake View	f	Available
RM0010708 	HTL00107	263.44	QUAD	Lake View	t	Available
RM0010709 	HTL00107	401.97	SUITE	Lake View	t	Available
RM0010710 	HTL00107	365.76	SINGLE	Garden View	f	Available
RM0010711 	HTL00107	322.58	DOUBLE	Garden View	t	Available
RM0010712 	HTL00107	226.47	QUAD	Forest View	t	Available
RM0010713 	HTL00107	220.42	DOUBLE	City View	f	Available
RM0010714 	HTL00107	105.73	DOUBLE	Sea View	t	Available
RM0010715 	HTL00107	182.30	SUITE	Skyline View	t	Available
RM0010800 	HTL00108	397.58	SUITE	Mountain View	t	Available
RM0010801 	HTL00108	346.23	SUITE	Pool View	f	Available
RM0010802 	HTL00108	465.38	SINGLE	Garden View	f	Available
RM0010803 	HTL00108	231.54	QUAD	Sea View	f	Available
RM0010804 	HTL00108	119.55	QUAD	Sea View	f	Available
RM0010805 	HTL00108	283.90	DOUBLE	Pool View	t	Available
RM0010806 	HTL00108	185.22	DOUBLE	Sea View	t	Available
RM0010807 	HTL00108	264.38	DOUBLE	Courtyard View	t	Available
RM0010808 	HTL00108	276.30	SINGLE	Mountain View	f	Available
RM0010809 	HTL00108	236.72	DOUBLE	Lake View	t	Available
RM0010810 	HTL00108	160.82	SINGLE	Skyline View	f	Available
RM0010811 	HTL00108	380.74	QUAD	River View	f	Available
RM0010812 	HTL00108	301.80	QUAD	Courtyard View	f	Available
RM0010813 	HTL00108	390.15	DOUBLE	Forest View	f	Available
RM0010814 	HTL00108	143.75	QUAD	Garden View	t	Available
RM0010815 	HTL00108	297.06	DOUBLE	Sea View	t	Available
RM0010900 	HTL00109	254.15	TRIPLE	City View	f	Available
RM0010901 	HTL00109	282.41	QUAD	River View	t	Available
RM0010902 	HTL00109	304.56	QUAD	Mountain View	f	Available
RM0010903 	HTL00109	233.01	TRIPLE	River View	f	Available
RM0010904 	HTL00109	250.81	TRIPLE	Forest View	f	Available
RM0010905 	HTL00109	272.58	DOUBLE	Mountain View	t	Available
RM0010906 	HTL00109	174.14	QUAD	Pool View	f	Available
RM0010907 	HTL00109	109.72	DOUBLE	Pool View	t	Available
RM0010908 	HTL00109	383.23	DOUBLE	City View	t	Available
RM0010909 	HTL00109	193.45	SUITE	Lake View	f	Available
RM0010910 	HTL00109	106.46	TRIPLE	Courtyard View	t	Available
RM0010911 	HTL00109	391.51	QUAD	Lake View	t	Available
RM0011000 	HTL00110	489.99	SINGLE	Pool View	t	Available
RM0011001 	HTL00110	274.01	DOUBLE	Pool View	t	Available
RM0011002 	HTL00110	269.05	QUAD	Courtyard View	f	Available
RM0011003 	HTL00110	375.08	SINGLE	River View	f	Available
RM0011004 	HTL00110	115.33	TRIPLE	City View	f	Available
RM0011005 	HTL00110	192.95	SINGLE	River View	f	Available
RM0011006 	HTL00110	384.15	TRIPLE	River View	t	Available
RM0011007 	HTL00110	257.07	SUITE	Pool View	t	Available
RM0011008 	HTL00110	374.09	SINGLE	Courtyard View	t	Available
RM0011009 	HTL00110	177.09	SUITE	Courtyard View	t	Available
RM0011010 	HTL00110	384.53	DOUBLE	City View	t	Available
RM0011011 	HTL00110	424.63	SUITE	Garden View	f	Available
RM0011012 	HTL00110	435.94	SUITE	Courtyard View	t	Available
RM0011013 	HTL00110	143.46	DOUBLE	Skyline View	f	Available
RM0011014 	HTL00110	188.88	DOUBLE	Mountain View	f	Available
RM0011015 	HTL00110	489.54	SINGLE	Skyline View	f	Available
RM0011016 	HTL00110	224.19	DOUBLE	Garden View	t	Available
RM0011017 	HTL00110	355.98	SUITE	Forest View	t	Available
RM0011100 	HTL00111	231.12	TRIPLE	Pool View	f	Available
RM0011101 	HTL00111	285.16	TRIPLE	River View	t	Available
RM0011102 	HTL00111	174.36	QUAD	Forest View	t	Available
RM0011103 	HTL00111	484.55	SUITE	Skyline View	f	Available
RM0011104 	HTL00111	457.62	SUITE	River View	f	Available
RM0011105 	HTL00111	330.64	DOUBLE	Skyline View	f	Available
RM0011106 	HTL00111	327.39	TRIPLE	Courtyard View	t	Available
RM0011107 	HTL00111	223.52	SINGLE	Pool View	f	Available
RM0011108 	HTL00111	254.01	QUAD	City View	t	Available
RM0011109 	HTL00111	359.86	SUITE	City View	t	Available
RM0011110 	HTL00111	412.94	QUAD	Garden View	t	Available
RM0011111 	HTL00111	128.55	QUAD	Courtyard View	t	Available
RM0011112 	HTL00111	306.93	QUAD	Courtyard View	f	Available
RM0011113 	HTL00111	205.86	TRIPLE	Mountain View	f	Available
RM0011114 	HTL00111	323.15	TRIPLE	Forest View	f	Available
RM0011115 	HTL00111	113.02	SUITE	Sea View	t	Available
RM0011200 	HTL00112	245.81	TRIPLE	Sea View	f	Available
RM0011201 	HTL00112	216.69	DOUBLE	River View	f	Available
RM0011202 	HTL00112	141.61	DOUBLE	Sea View	f	Available
RM0011203 	HTL00112	308.68	SINGLE	City View	f	Available
RM0011204 	HTL00112	119.89	SUITE	Lake View	t	Available
RM0011205 	HTL00112	220.04	TRIPLE	Skyline View	f	Available
RM0011206 	HTL00112	483.72	SUITE	City View	f	Available
RM0011207 	HTL00112	171.95	TRIPLE	River View	f	Available
RM0011208 	HTL00112	340.85	TRIPLE	Skyline View	f	Available
RM0011209 	HTL00112	126.19	DOUBLE	Sea View	t	Available
RM0011210 	HTL00112	213.40	TRIPLE	City View	t	Available
RM0011211 	HTL00112	417.45	TRIPLE	Garden View	t	Available
RM0011212 	HTL00112	405.59	SINGLE	Mountain View	f	Available
RM0011213 	HTL00112	316.84	SINGLE	Courtyard View	f	Available
RM0011214 	HTL00112	212.41	SINGLE	Courtyard View	f	Available
RM0011215 	HTL00112	166.48	QUAD	Courtyard View	t	Available
RM0011216 	HTL00112	362.88	DOUBLE	Courtyard View	f	Available
RM0011217 	HTL00112	389.66	DOUBLE	River View	t	Available
RM0011300 	HTL00113	434.70	QUAD	Pool View	t	Available
RM0011301 	HTL00113	325.97	SUITE	Pool View	t	Available
RM0011302 	HTL00113	219.80	SINGLE	River View	f	Available
RM0011303 	HTL00113	436.54	DOUBLE	Courtyard View	t	Available
RM0011304 	HTL00113	391.66	DOUBLE	Lake View	f	Available
RM0011305 	HTL00113	429.81	QUAD	Sea View	f	Available
RM0011306 	HTL00113	420.10	QUAD	Forest View	f	Available
RM0011307 	HTL00113	378.88	TRIPLE	Lake View	t	Available
RM0011308 	HTL00113	114.72	SUITE	Lake View	f	Available
RM0011309 	HTL00113	383.18	DOUBLE	River View	t	Available
RM0011310 	HTL00113	402.24	SINGLE	Garden View	t	Available
RM0011311 	HTL00113	336.99	DOUBLE	Skyline View	f	Available
RM0011312 	HTL00113	293.58	QUAD	Sea View	t	Available
RM0011313 	HTL00113	351.09	DOUBLE	Sea View	t	Available
RM0011314 	HTL00113	274.23	QUAD	Skyline View	t	Available
RM0011315 	HTL00113	435.20	SUITE	City View	f	Available
RM0011400 	HTL00114	499.46	SINGLE	City View	t	Available
RM0011401 	HTL00114	401.33	SINGLE	Sea View	f	Available
RM0011402 	HTL00114	176.54	SINGLE	Forest View	t	Available
RM0011403 	HTL00114	130.90	TRIPLE	City View	t	Available
RM0011404 	HTL00114	124.43	DOUBLE	Lake View	f	Available
RM0011405 	HTL00114	493.37	SINGLE	Pool View	f	Available
RM0011406 	HTL00114	261.65	QUAD	Mountain View	t	Available
RM0011407 	HTL00114	225.47	DOUBLE	Skyline View	t	Available
RM0011408 	HTL00114	401.20	QUAD	Lake View	t	Available
RM0011409 	HTL00114	288.56	SUITE	River View	t	Available
RM0011410 	HTL00114	437.19	SINGLE	Pool View	t	Available
RM0011411 	HTL00114	427.45	DOUBLE	Mountain View	t	Available
RM0011412 	HTL00114	301.29	SINGLE	Skyline View	t	Available
RM0011500 	HTL00115	420.87	SINGLE	Forest View	t	Available
RM0011501 	HTL00115	224.24	QUAD	City View	t	Available
RM0011502 	HTL00115	261.71	SINGLE	Lake View	f	Available
RM0011503 	HTL00115	263.56	TRIPLE	Garden View	f	Available
RM0011504 	HTL00115	222.18	QUAD	City View	f	Available
RM0011505 	HTL00115	250.65	SINGLE	River View	f	Available
RM0011506 	HTL00115	182.84	SINGLE	Pool View	t	Available
RM0011507 	HTL00115	403.63	SINGLE	Skyline View	t	Available
RM0011508 	HTL00115	397.89	TRIPLE	City View	t	Available
RM0011509 	HTL00115	418.14	SUITE	Lake View	f	Available
RM0011510 	HTL00115	369.39	TRIPLE	River View	f	Available
RM0011511 	HTL00115	192.65	SINGLE	Pool View	f	Available
RM0011512 	HTL00115	320.59	SINGLE	Skyline View	t	Available
RM0011513 	HTL00115	358.35	DOUBLE	Skyline View	f	Available
RM0011514 	HTL00115	368.05	SINGLE	City View	f	Available
RM0011515 	HTL00115	213.93	TRIPLE	Forest View	t	Available
RM0011516 	HTL00115	100.66	SINGLE	Lake View	t	Available
RM0011517 	HTL00115	131.48	SUITE	Forest View	t	Available
RM0011600 	HTL00116	133.42	DOUBLE	Forest View	t	Available
RM0011601 	HTL00116	427.79	SUITE	Sea View	t	Available
RM0011602 	HTL00116	242.39	SUITE	Skyline View	t	Available
RM0011603 	HTL00116	425.67	SINGLE	Courtyard View	t	Available
RM0011604 	HTL00116	196.36	TRIPLE	Sea View	t	Available
RM0011605 	HTL00116	314.17	SINGLE	City View	f	Available
RM0011606 	HTL00116	378.39	TRIPLE	Lake View	t	Available
RM0011607 	HTL00116	301.67	SUITE	Sea View	f	Available
RM0011608 	HTL00116	396.77	SUITE	Pool View	f	Available
RM0011609 	HTL00116	347.19	SUITE	River View	t	Available
RM0011610 	HTL00116	346.92	SUITE	Garden View	t	Available
RM0011611 	HTL00116	251.63	QUAD	River View	t	Available
RM0011612 	HTL00116	224.98	SINGLE	River View	f	Available
RM0011613 	HTL00116	375.32	SINGLE	City View	f	Available
RM0011614 	HTL00116	418.90	SINGLE	Mountain View	t	Available
RM0011615 	HTL00116	414.47	TRIPLE	Lake View	f	Available
RM0011616 	HTL00116	217.21	QUAD	Sea View	f	Available
RM0011617 	HTL00116	373.28	TRIPLE	Lake View	f	Available
RM0011700 	HTL00117	176.26	SUITE	Mountain View	t	Available
RM0011701 	HTL00117	343.06	SUITE	City View	f	Available
RM0011702 	HTL00117	394.89	SUITE	Courtyard View	f	Available
RM0011703 	HTL00117	465.30	SUITE	Forest View	f	Available
RM0011704 	HTL00117	117.31	QUAD	Sea View	t	Available
RM0011705 	HTL00117	497.65	SUITE	River View	t	Available
RM0011706 	HTL00117	290.54	SUITE	River View	t	Available
RM0011707 	HTL00117	185.39	SINGLE	Lake View	f	Available
RM0011708 	HTL00117	459.73	DOUBLE	Skyline View	t	Available
RM0011709 	HTL00117	222.47	SINGLE	Courtyard View	f	Available
RM0011710 	HTL00117	106.36	QUAD	Skyline View	f	Available
RM0011711 	HTL00117	358.48	TRIPLE	Pool View	f	Available
RM0011712 	HTL00117	427.61	DOUBLE	City View	t	Available
RM0011713 	HTL00117	296.79	SINGLE	Skyline View	t	Available
RM0011714 	HTL00117	102.09	SINGLE	Garden View	t	Available
RM0011800 	HTL00118	298.37	TRIPLE	Skyline View	t	Available
RM0011801 	HTL00118	445.95	QUAD	Skyline View	t	Available
RM0011802 	HTL00118	274.11	SINGLE	River View	t	Available
RM0011803 	HTL00118	148.80	SUITE	River View	f	Available
RM0011804 	HTL00118	381.77	QUAD	River View	f	Available
RM0011805 	HTL00118	203.08	TRIPLE	Garden View	f	Available
RM0011806 	HTL00118	385.75	QUAD	Forest View	f	Available
RM0011807 	HTL00118	226.49	DOUBLE	City View	t	Available
RM0011808 	HTL00118	475.20	SINGLE	Sea View	f	Available
RM0011809 	HTL00118	480.51	DOUBLE	Sea View	t	Available
RM0011810 	HTL00118	186.89	QUAD	Courtyard View	f	Available
RM0011811 	HTL00118	128.38	TRIPLE	Sea View	t	Available
RM0011900 	HTL00119	329.54	SUITE	Courtyard View	t	Available
RM0011901 	HTL00119	362.56	DOUBLE	Forest View	f	Available
RM0011902 	HTL00119	169.41	DOUBLE	River View	f	Available
RM0011903 	HTL00119	149.85	QUAD	Sea View	f	Available
RM0011904 	HTL00119	282.86	QUAD	City View	f	Available
RM0011905 	HTL00119	138.75	SINGLE	Skyline View	t	Available
RM0011906 	HTL00119	100.22	SINGLE	City View	t	Available
RM0011907 	HTL00119	176.13	TRIPLE	Lake View	f	Available
RM0011908 	HTL00119	113.47	DOUBLE	Lake View	f	Available
RM0011909 	HTL00119	325.03	QUAD	Lake View	t	Available
RM0011910 	HTL00119	277.20	SINGLE	Courtyard View	t	Available
RM0012000 	HTL00120	184.73	SINGLE	Lake View	t	Available
RM0012001 	HTL00120	341.82	SINGLE	Skyline View	f	Available
RM0012002 	HTL00120	357.00	DOUBLE	Forest View	f	Available
RM0012003 	HTL00120	252.04	DOUBLE	River View	t	Available
RM0012004 	HTL00120	258.29	DOUBLE	Mountain View	f	Available
RM0012005 	HTL00120	256.81	QUAD	Forest View	t	Available
RM0012006 	HTL00120	142.36	TRIPLE	Courtyard View	t	Available
RM0012007 	HTL00120	320.58	TRIPLE	Courtyard View	f	Available
RM0012008 	HTL00120	205.70	TRIPLE	Mountain View	t	Available
RM0012009 	HTL00120	366.06	QUAD	Courtyard View	t	Available
RM0012010 	HTL00120	169.08	TRIPLE	Skyline View	f	Available
RM0012011 	HTL00120	124.75	DOUBLE	Sea View	t	Available
RM0012100 	HTL00121	479.50	DOUBLE	Forest View	f	Available
RM0012101 	HTL00121	269.91	TRIPLE	Sea View	f	Available
RM0012102 	HTL00121	254.67	DOUBLE	Lake View	t	Available
RM0012103 	HTL00121	366.56	DOUBLE	River View	t	Available
RM0012104 	HTL00121	233.55	TRIPLE	Pool View	f	Available
RM0012105 	HTL00121	294.08	TRIPLE	City View	t	Available
RM0012106 	HTL00121	300.21	QUAD	River View	f	Available
RM0012107 	HTL00121	213.99	QUAD	Lake View	f	Available
RM0012108 	HTL00121	313.38	DOUBLE	Mountain View	f	Available
RM0012109 	HTL00121	282.57	SUITE	Courtyard View	f	Available
RM0012110 	HTL00121	394.46	SINGLE	Garden View	f	Available
RM0012111 	HTL00121	192.29	QUAD	Forest View	t	Available
RM0012112 	HTL00121	174.64	DOUBLE	River View	t	Available
RM0012200 	HTL00122	331.25	TRIPLE	Garden View	t	Available
RM0012201 	HTL00122	491.62	DOUBLE	Mountain View	t	Available
RM0012202 	HTL00122	165.42	SUITE	Mountain View	t	Available
RM0012203 	HTL00122	109.34	TRIPLE	Sea View	f	Available
RM0012204 	HTL00122	225.56	DOUBLE	Forest View	f	Available
RM0012205 	HTL00122	209.02	SUITE	City View	f	Available
RM0012206 	HTL00122	132.11	SINGLE	Skyline View	t	Available
RM0012207 	HTL00122	427.57	SUITE	Pool View	t	Available
RM0012208 	HTL00122	323.54	SINGLE	City View	f	Available
RM0012209 	HTL00122	354.09	SUITE	City View	f	Available
RM0012210 	HTL00122	496.32	DOUBLE	Garden View	t	Available
RM0012211 	HTL00122	159.80	DOUBLE	Courtyard View	t	Available
RM0012212 	HTL00122	225.40	SINGLE	Lake View	t	Available
RM0012213 	HTL00122	274.14	QUAD	Garden View	f	Available
RM0012214 	HTL00122	209.72	SUITE	City View	t	Available
RM0012215 	HTL00122	395.17	SINGLE	Courtyard View	t	Available
RM0012216 	HTL00122	301.53	SUITE	Forest View	f	Available
RM0020000 	HTL00200	101.03	SUITE	Forest View	f	Available
RM0020001 	HTL00200	100.45	TRIPLE	Forest View	f	Available
RM0020002 	HTL00200	267.78	QUAD	Skyline View	f	Available
RM0020003 	HTL00200	153.94	TRIPLE	Pool View	t	Available
RM0020004 	HTL00200	470.40	DOUBLE	Skyline View	t	Available
RM0020005 	HTL00200	319.00	QUAD	Mountain View	f	Available
RM0020006 	HTL00200	278.29	SUITE	Pool View	f	Available
RM0020007 	HTL00200	107.53	SUITE	River View	f	Available
RM0020008 	HTL00200	306.13	SINGLE	Forest View	f	Available
RM0020009 	HTL00200	145.81	QUAD	Sea View	t	Available
RM0020100 	HTL00201	316.83	TRIPLE	Forest View	t	Available
RM0020101 	HTL00201	351.60	TRIPLE	Garden View	f	Available
RM0020102 	HTL00201	370.79	DOUBLE	Mountain View	t	Available
RM0020103 	HTL00201	364.14	SINGLE	Forest View	f	Available
RM0020104 	HTL00201	218.81	SINGLE	Skyline View	t	Available
RM0020105 	HTL00201	242.22	SINGLE	Courtyard View	f	Available
RM0020106 	HTL00201	145.07	SUITE	Pool View	f	Available
RM0020107 	HTL00201	342.74	DOUBLE	Pool View	t	Available
RM0020108 	HTL00201	359.50	DOUBLE	River View	t	Available
RM0020109 	HTL00201	477.29	QUAD	City View	t	Available
RM0020110 	HTL00201	270.24	TRIPLE	Lake View	f	Available
RM0020111 	HTL00201	342.47	SINGLE	Pool View	f	Available
RM0020112 	HTL00201	238.21	TRIPLE	Mountain View	f	Available
RM0020113 	HTL00201	224.80	SINGLE	Skyline View	t	Available
RM0020114 	HTL00201	480.26	DOUBLE	Mountain View	t	Available
RM0020115 	HTL00201	175.41	SINGLE	Lake View	t	Available
RM0020116 	HTL00201	313.18	SUITE	River View	t	Available
RM0020117 	HTL00201	123.81	DOUBLE	Garden View	f	Available
RM0020118 	HTL00201	365.49	QUAD	Skyline View	f	Available
RM0020200 	HTL00202	421.64	QUAD	River View	t	Available
RM0020201 	HTL00202	436.10	QUAD	Garden View	t	Available
RM0020202 	HTL00202	120.66	TRIPLE	Forest View	f	Available
RM0020203 	HTL00202	183.64	QUAD	Garden View	t	Available
RM0020204 	HTL00202	461.52	DOUBLE	Garden View	f	Available
RM0020205 	HTL00202	135.92	QUAD	Pool View	f	Available
RM0020206 	HTL00202	195.51	SUITE	Sea View	t	Available
RM0020207 	HTL00202	394.17	QUAD	Forest View	t	Available
RM0020208 	HTL00202	425.88	DOUBLE	Pool View	f	Available
RM0020209 	HTL00202	221.06	DOUBLE	Skyline View	t	Available
RM0020210 	HTL00202	253.47	SUITE	Courtyard View	f	Available
RM0020211 	HTL00202	252.38	QUAD	Garden View	f	Available
RM0020212 	HTL00202	177.82	QUAD	Skyline View	t	Available
RM0020213 	HTL00202	113.07	TRIPLE	Sea View	f	Available
RM0020214 	HTL00202	134.56	DOUBLE	Lake View	f	Available
RM0020215 	HTL00202	132.62	SUITE	River View	t	Available
RM0020216 	HTL00202	132.25	TRIPLE	Sea View	f	Available
RM0020300 	HTL00203	307.06	TRIPLE	Forest View	t	Available
RM0020301 	HTL00203	361.13	TRIPLE	Sea View	f	Available
RM0020302 	HTL00203	340.16	QUAD	River View	t	Available
RM0020303 	HTL00203	178.23	SUITE	Pool View	f	Available
RM0020304 	HTL00203	307.80	QUAD	Forest View	f	Available
RM0020305 	HTL00203	171.92	QUAD	Garden View	f	Available
RM0020306 	HTL00203	113.32	TRIPLE	Forest View	t	Available
RM0020307 	HTL00203	336.48	SINGLE	Skyline View	t	Available
RM0020308 	HTL00203	239.86	DOUBLE	River View	t	Available
RM0020309 	HTL00203	490.37	TRIPLE	Courtyard View	f	Available
RM0020310 	HTL00203	158.47	SUITE	Garden View	t	Available
RM0020311 	HTL00203	494.76	QUAD	River View	f	Available
RM0020312 	HTL00203	115.84	SINGLE	Skyline View	t	Available
RM0020313 	HTL00203	448.91	DOUBLE	Forest View	t	Available
RM0020314 	HTL00203	192.49	QUAD	Courtyard View	t	Available
RM0020315 	HTL00203	384.23	SINGLE	River View	t	Available
RM0020316 	HTL00203	214.69	TRIPLE	River View	t	Available
RM0020317 	HTL00203	305.61	SINGLE	City View	t	Available
RM0020400 	HTL00204	282.58	TRIPLE	City View	f	Available
RM0020401 	HTL00204	400.26	SUITE	Courtyard View	t	Available
RM0020402 	HTL00204	247.76	TRIPLE	Lake View	f	Available
RM0020403 	HTL00204	272.11	SUITE	River View	f	Available
RM0020404 	HTL00204	417.16	TRIPLE	Garden View	f	Available
RM0020405 	HTL00204	144.30	SINGLE	Garden View	f	Available
RM0020406 	HTL00204	168.02	DOUBLE	Lake View	t	Available
RM0020407 	HTL00204	474.31	DOUBLE	City View	f	Available
RM0020408 	HTL00204	202.98	DOUBLE	Mountain View	f	Available
RM0020409 	HTL00204	120.88	DOUBLE	Sea View	f	Available
RM0020410 	HTL00204	478.18	DOUBLE	Mountain View	f	Available
RM0020411 	HTL00204	243.61	SUITE	Sea View	t	Available
RM0020500 	HTL00205	169.68	SUITE	Mountain View	t	Available
RM0020501 	HTL00205	349.25	TRIPLE	City View	t	Available
RM0020502 	HTL00205	101.49	SUITE	Garden View	t	Available
RM0020503 	HTL00205	234.44	TRIPLE	Forest View	t	Available
RM0020504 	HTL00205	404.75	SUITE	Garden View	f	Available
RM0020505 	HTL00205	435.22	TRIPLE	Lake View	f	Available
RM0020506 	HTL00205	381.64	QUAD	Mountain View	f	Available
RM0020507 	HTL00205	185.71	SINGLE	Garden View	t	Available
RM0020508 	HTL00205	323.44	SUITE	River View	f	Available
RM0020509 	HTL00205	233.07	SUITE	Sea View	t	Available
RM0020510 	HTL00205	327.83	QUAD	Sea View	f	Available
RM0020511 	HTL00205	273.02	TRIPLE	Forest View	t	Available
RM0020512 	HTL00205	223.41	SINGLE	Pool View	f	Available
RM0020513 	HTL00205	342.35	QUAD	Courtyard View	t	Available
RM0020514 	HTL00205	315.81	TRIPLE	Pool View	f	Available
RM0020600 	HTL00206	203.12	DOUBLE	Pool View	f	Available
RM0020601 	HTL00206	234.26	QUAD	Garden View	f	Available
RM0020602 	HTL00206	244.18	SUITE	City View	t	Available
RM0020603 	HTL00206	141.16	QUAD	Courtyard View	f	Available
RM0020604 	HTL00206	460.13	TRIPLE	City View	f	Available
RM0020605 	HTL00206	456.13	SINGLE	River View	f	Available
RM0020606 	HTL00206	306.43	DOUBLE	River View	t	Available
RM0020607 	HTL00206	422.78	SUITE	Garden View	f	Available
RM0020608 	HTL00206	433.15	SUITE	Forest View	f	Available
RM0020609 	HTL00206	477.56	QUAD	Garden View	f	Available
RM0020610 	HTL00206	376.74	QUAD	Courtyard View	t	Available
RM0020611 	HTL00206	213.92	SUITE	Garden View	f	Available
RM0020612 	HTL00206	358.91	SUITE	Courtyard View	t	Available
RM0020613 	HTL00206	271.38	DOUBLE	Courtyard View	t	Available
RM0020700 	HTL00207	184.23	SUITE	Mountain View	f	Available
RM0020701 	HTL00207	236.10	SINGLE	River View	f	Available
RM0020702 	HTL00207	143.93	SINGLE	City View	f	Available
RM0020703 	HTL00207	366.74	SINGLE	Lake View	f	Available
RM0020704 	HTL00207	159.67	SUITE	River View	t	Available
RM0020705 	HTL00207	202.51	QUAD	Sea View	t	Available
RM0020706 	HTL00207	151.89	QUAD	Pool View	f	Available
RM0020707 	HTL00207	404.23	DOUBLE	Courtyard View	f	Available
RM0020708 	HTL00207	212.02	QUAD	Courtyard View	t	Available
RM0020709 	HTL00207	475.04	DOUBLE	Pool View	f	Available
RM0020710 	HTL00207	106.65	QUAD	Lake View	t	Available
RM0020711 	HTL00207	379.95	DOUBLE	River View	t	Available
RM0020712 	HTL00207	228.33	DOUBLE	Skyline View	f	Available
RM0020713 	HTL00207	192.29	SUITE	Mountain View	t	Available
RM0020800 	HTL00208	396.42	DOUBLE	Courtyard View	t	Available
RM0020801 	HTL00208	424.90	SINGLE	Mountain View	f	Available
RM0020802 	HTL00208	287.49	TRIPLE	Skyline View	t	Available
RM0020803 	HTL00208	138.11	SINGLE	Mountain View	t	Available
RM0020804 	HTL00208	115.40	SUITE	Lake View	f	Available
RM0020805 	HTL00208	458.83	QUAD	Courtyard View	t	Available
RM0020806 	HTL00208	466.35	SINGLE	Courtyard View	t	Available
RM0020807 	HTL00208	452.70	SUITE	City View	f	Available
RM0020808 	HTL00208	401.35	QUAD	Lake View	t	Available
RM0020809 	HTL00208	115.02	DOUBLE	Forest View	t	Available
RM0020810 	HTL00208	143.88	SUITE	Mountain View	f	Available
RM0020811 	HTL00208	482.04	DOUBLE	Forest View	t	Available
RM0020812 	HTL00208	416.89	QUAD	Lake View	t	Available
RM0020813 	HTL00208	103.00	QUAD	Courtyard View	f	Available
RM0020814 	HTL00208	477.03	QUAD	Pool View	t	Available
RM0020815 	HTL00208	154.94	QUAD	Lake View	t	Available
RM0020816 	HTL00208	121.12	QUAD	Sea View	t	Available
RM0020817 	HTL00208	360.67	DOUBLE	Lake View	f	Available
RM0020818 	HTL00208	409.58	SUITE	Garden View	f	Available
RM0020900 	HTL00209	294.65	DOUBLE	River View	t	Available
RM0020901 	HTL00209	283.39	SINGLE	Sea View	f	Available
RM0020902 	HTL00209	430.50	TRIPLE	Courtyard View	t	Available
RM0020903 	HTL00209	115.33	TRIPLE	Courtyard View	t	Available
RM0020904 	HTL00209	284.72	SINGLE	Mountain View	f	Available
RM0020905 	HTL00209	120.98	TRIPLE	Skyline View	t	Available
RM0020906 	HTL00209	176.27	DOUBLE	Skyline View	f	Available
RM0020907 	HTL00209	455.62	SUITE	City View	t	Available
RM0020908 	HTL00209	358.04	TRIPLE	Mountain View	t	Available
RM0020909 	HTL00209	124.54	TRIPLE	City View	f	Available
RM0020910 	HTL00209	488.71	QUAD	Pool View	f	Available
RM0020911 	HTL00209	174.88	TRIPLE	Sea View	f	Available
RM0021000 	HTL00210	256.03	TRIPLE	Garden View	t	Available
RM0021001 	HTL00210	167.09	DOUBLE	River View	t	Available
RM0021002 	HTL00210	203.77	TRIPLE	Mountain View	f	Available
RM0021003 	HTL00210	479.02	QUAD	River View	t	Available
RM0021004 	HTL00210	254.23	SINGLE	Forest View	f	Available
RM0021005 	HTL00210	160.17	DOUBLE	Skyline View	t	Available
RM0021006 	HTL00210	280.18	TRIPLE	Garden View	f	Available
RM0021007 	HTL00210	252.82	SINGLE	Lake View	t	Available
RM0021008 	HTL00210	396.53	SINGLE	Courtyard View	f	Available
RM0021009 	HTL00210	225.54	DOUBLE	City View	t	Available
RM0021010 	HTL00210	335.83	QUAD	Mountain View	t	Available
RM0021011 	HTL00210	298.21	TRIPLE	Lake View	t	Available
RM0021012 	HTL00210	334.11	SUITE	City View	t	Available
RM0021013 	HTL00210	475.37	TRIPLE	Garden View	t	Available
RM0021100 	HTL00211	164.60	SUITE	Forest View	f	Available
RM0021101 	HTL00211	358.01	TRIPLE	Courtyard View	t	Available
RM0021102 	HTL00211	209.45	TRIPLE	Pool View	f	Available
RM0021103 	HTL00211	281.71	SINGLE	Lake View	t	Available
RM0021104 	HTL00211	325.68	SINGLE	Forest View	t	Available
RM0021105 	HTL00211	332.07	QUAD	Forest View	t	Available
RM0021106 	HTL00211	333.92	SUITE	Skyline View	t	Available
RM0021107 	HTL00211	143.94	SINGLE	Sea View	f	Available
RM0021108 	HTL00211	186.07	SINGLE	Forest View	f	Available
RM0021109 	HTL00211	254.81	SUITE	Courtyard View	f	Available
RM0021110 	HTL00211	470.69	TRIPLE	Garden View	t	Available
RM0021111 	HTL00211	350.57	SINGLE	Pool View	f	Available
RM0021112 	HTL00211	128.04	SINGLE	Sea View	f	Available
RM0021113 	HTL00211	111.32	SINGLE	River View	t	Available
RM0021114 	HTL00211	173.23	DOUBLE	Mountain View	t	Available
RM0021115 	HTL00211	429.71	SUITE	Mountain View	t	Available
RM0021116 	HTL00211	112.96	TRIPLE	City View	f	Available
RM0021117 	HTL00211	419.40	TRIPLE	Forest View	f	Available
RM0021118 	HTL00211	184.16	QUAD	Pool View	t	Available
RM0021200 	HTL00212	345.37	QUAD	Sea View	f	Available
RM0021201 	HTL00212	460.45	SINGLE	Sea View	f	Available
RM0021202 	HTL00212	332.05	SINGLE	Garden View	t	Available
RM0021203 	HTL00212	443.21	SINGLE	City View	f	Available
RM0021204 	HTL00212	270.75	TRIPLE	Mountain View	f	Available
RM0021205 	HTL00212	459.12	TRIPLE	City View	f	Available
RM0021206 	HTL00212	455.77	SINGLE	Skyline View	f	Available
RM0021207 	HTL00212	283.60	SUITE	City View	t	Available
RM0021208 	HTL00212	288.25	DOUBLE	Mountain View	t	Available
RM0021209 	HTL00212	489.33	DOUBLE	Lake View	t	Available
RM0021210 	HTL00212	225.34	TRIPLE	Garden View	f	Available
RM0021211 	HTL00212	125.11	TRIPLE	Skyline View	t	Available
RM0021212 	HTL00212	339.59	SUITE	Lake View	f	Available
RM0021213 	HTL00212	428.57	DOUBLE	Garden View	f	Available
RM0021214 	HTL00212	393.91	DOUBLE	Sea View	t	Available
RM0021215 	HTL00212	285.52	QUAD	Skyline View	f	Available
RM0021216 	HTL00212	479.92	SUITE	Garden View	f	Available
RM0021217 	HTL00212	151.02	TRIPLE	City View	t	Available
RM0021300 	HTL00213	386.31	DOUBLE	Skyline View	f	Available
RM0021301 	HTL00213	434.72	QUAD	River View	f	Available
RM0021302 	HTL00213	260.27	SUITE	Forest View	t	Available
RM0021303 	HTL00213	339.44	SUITE	Sea View	t	Available
RM0021304 	HTL00213	431.73	TRIPLE	Forest View	f	Available
RM0021305 	HTL00213	365.47	SINGLE	Mountain View	f	Available
RM0021306 	HTL00213	493.84	SUITE	Mountain View	f	Available
RM0021307 	HTL00213	101.79	QUAD	Sea View	f	Available
RM0021308 	HTL00213	373.98	TRIPLE	River View	t	Available
RM0021309 	HTL00213	149.63	DOUBLE	Mountain View	t	Available
RM0021400 	HTL00214	377.13	SINGLE	Sea View	f	Available
RM0021401 	HTL00214	234.22	SINGLE	Skyline View	f	Available
RM0021402 	HTL00214	191.55	SUITE	City View	t	Available
RM0021403 	HTL00214	232.94	DOUBLE	Forest View	t	Available
RM0021404 	HTL00214	485.08	DOUBLE	Forest View	t	Available
RM0021405 	HTL00214	363.50	SINGLE	Garden View	t	Available
RM0021406 	HTL00214	431.00	SINGLE	Sea View	t	Available
RM0021407 	HTL00214	403.50	DOUBLE	Pool View	t	Available
RM0021408 	HTL00214	151.49	TRIPLE	Forest View	f	Available
RM0021409 	HTL00214	202.16	TRIPLE	Forest View	f	Available
RM0021410 	HTL00214	168.59	QUAD	River View	f	Available
RM0021411 	HTL00214	159.94	DOUBLE	Mountain View	f	Available
RM0021500 	HTL00215	153.38	QUAD	Skyline View	f	Available
RM0021501 	HTL00215	139.22	TRIPLE	Forest View	t	Available
RM0021502 	HTL00215	119.35	TRIPLE	River View	t	Available
RM0021503 	HTL00215	446.27	DOUBLE	Skyline View	t	Available
RM0021504 	HTL00215	408.10	DOUBLE	Forest View	t	Available
RM0021505 	HTL00215	413.46	QUAD	Forest View	t	Available
RM0021506 	HTL00215	420.82	DOUBLE	River View	t	Available
RM0021507 	HTL00215	235.31	DOUBLE	Skyline View	f	Available
RM0021508 	HTL00215	192.75	SINGLE	Skyline View	t	Available
RM0021509 	HTL00215	298.53	TRIPLE	Forest View	f	Available
RM0021510 	HTL00215	382.92	TRIPLE	Courtyard View	t	Available
RM0021511 	HTL00215	482.90	DOUBLE	Pool View	t	Available
RM0021512 	HTL00215	463.72	DOUBLE	Forest View	t	Available
RM0021600 	HTL00216	237.17	SUITE	City View	t	Available
RM0021601 	HTL00216	474.70	TRIPLE	Pool View	f	Available
RM0021602 	HTL00216	170.23	SINGLE	Pool View	t	Available
RM0021603 	HTL00216	299.41	TRIPLE	River View	t	Available
RM0021604 	HTL00216	488.99	TRIPLE	Courtyard View	t	Available
RM0021605 	HTL00216	458.17	SINGLE	Mountain View	t	Available
RM0021606 	HTL00216	489.07	TRIPLE	Sea View	f	Available
RM0021607 	HTL00216	196.65	TRIPLE	Sea View	t	Available
RM0021608 	HTL00216	325.58	SUITE	Forest View	f	Available
RM0021609 	HTL00216	296.54	SUITE	Garden View	t	Available
RM0021610 	HTL00216	156.52	SUITE	Skyline View	t	Available
RM0021611 	HTL00216	243.29	TRIPLE	Lake View	f	Available
RM0021612 	HTL00216	327.25	QUAD	Courtyard View	t	Available
RM0021700 	HTL00217	292.25	SINGLE	Lake View	t	Available
RM0021701 	HTL00217	373.52	TRIPLE	Pool View	t	Available
RM0021702 	HTL00217	282.28	SINGLE	Lake View	t	Available
RM0021703 	HTL00217	230.99	DOUBLE	Pool View	t	Available
RM0021704 	HTL00217	142.37	SINGLE	Pool View	t	Available
RM0021705 	HTL00217	163.36	TRIPLE	Lake View	f	Available
RM0021706 	HTL00217	161.74	DOUBLE	Lake View	t	Available
RM0021707 	HTL00217	472.66	QUAD	Pool View	f	Available
RM0021708 	HTL00217	304.83	QUAD	Garden View	f	Available
RM0021709 	HTL00217	287.70	SUITE	Mountain View	t	Available
RM0021710 	HTL00217	102.44	TRIPLE	Forest View	t	Available
RM0021711 	HTL00217	291.21	QUAD	Garden View	t	Available
RM0021712 	HTL00217	330.75	DOUBLE	Lake View	t	Available
RM0021713 	HTL00217	319.44	SUITE	Mountain View	f	Available
RM0030000 	HTL00300	411.95	SUITE	River View	t	Available
RM0030001 	HTL00300	338.77	DOUBLE	Mountain View	t	Available
RM0030002 	HTL00300	475.03	QUAD	River View	t	Available
RM0030003 	HTL00300	344.02	DOUBLE	Sea View	f	Available
RM0030004 	HTL00300	351.94	QUAD	Lake View	f	Available
RM0030005 	HTL00300	294.44	SINGLE	Lake View	t	Available
RM0030006 	HTL00300	226.38	DOUBLE	Pool View	f	Available
RM0030007 	HTL00300	227.06	SUITE	River View	f	Available
RM0030008 	HTL00300	184.75	QUAD	Mountain View	f	Available
RM0030009 	HTL00300	153.95	SINGLE	Sea View	t	Available
RM0030010 	HTL00300	472.18	QUAD	Lake View	t	Available
RM0030011 	HTL00300	472.39	TRIPLE	Garden View	t	Available
RM0030012 	HTL00300	171.11	DOUBLE	Sea View	t	Available
RM0030013 	HTL00300	350.77	SUITE	Skyline View	t	Available
RM0030014 	HTL00300	379.16	QUAD	Courtyard View	t	Available
RM0030015 	HTL00300	136.15	SINGLE	Skyline View	t	Available
RM0030016 	HTL00300	492.53	QUAD	Mountain View	f	Available
RM0030017 	HTL00300	235.21	DOUBLE	Lake View	f	Available
RM0030100 	HTL00301	440.56	TRIPLE	Garden View	t	Available
RM0030101 	HTL00301	260.45	TRIPLE	Lake View	f	Available
RM0030102 	HTL00301	182.43	QUAD	Courtyard View	f	Available
RM0030103 	HTL00301	309.92	SINGLE	Lake View	f	Available
RM0030104 	HTL00301	330.21	SUITE	Mountain View	t	Available
RM0030105 	HTL00301	379.54	TRIPLE	Mountain View	f	Available
RM0030106 	HTL00301	254.16	QUAD	Forest View	f	Available
RM0030107 	HTL00301	379.29	QUAD	Lake View	t	Available
RM0030108 	HTL00301	147.99	DOUBLE	Mountain View	t	Available
RM0030109 	HTL00301	400.18	QUAD	Skyline View	t	Available
RM0030110 	HTL00301	325.24	TRIPLE	Mountain View	t	Available
RM0030111 	HTL00301	492.26	SINGLE	Sea View	t	Available
RM0030112 	HTL00301	319.88	TRIPLE	Forest View	t	Available
RM0030113 	HTL00301	241.37	DOUBLE	Courtyard View	t	Available
RM0030114 	HTL00301	259.45	QUAD	Lake View	f	Available
RM0030115 	HTL00301	186.81	QUAD	Lake View	f	Available
RM0030200 	HTL00302	118.73	SINGLE	Skyline View	t	Available
RM0030201 	HTL00302	146.08	SUITE	River View	t	Available
RM0030202 	HTL00302	202.95	QUAD	Garden View	t	Available
RM0030203 	HTL00302	276.78	TRIPLE	Garden View	t	Available
RM0030204 	HTL00302	366.82	SUITE	Garden View	t	Available
RM0030205 	HTL00302	218.43	TRIPLE	City View	f	Available
RM0030206 	HTL00302	338.83	SINGLE	Skyline View	t	Available
RM0030207 	HTL00302	408.70	QUAD	City View	f	Available
RM0030208 	HTL00302	230.06	DOUBLE	Garden View	f	Available
RM0030209 	HTL00302	134.99	DOUBLE	Lake View	t	Available
RM0030210 	HTL00302	142.77	DOUBLE	City View	t	Available
RM0030300 	HTL00303	466.64	SUITE	Sea View	t	Available
RM0030301 	HTL00303	157.38	SUITE	Pool View	t	Available
RM0030302 	HTL00303	392.94	SUITE	Forest View	f	Available
RM0030303 	HTL00303	456.57	TRIPLE	Pool View	f	Available
RM0030304 	HTL00303	368.53	DOUBLE	River View	f	Available
RM0030305 	HTL00303	335.46	SUITE	City View	f	Available
RM0030306 	HTL00303	115.53	QUAD	Sea View	f	Available
RM0030307 	HTL00303	283.54	DOUBLE	Pool View	f	Available
RM0030308 	HTL00303	387.74	TRIPLE	Mountain View	f	Available
RM0030309 	HTL00303	332.10	QUAD	Forest View	t	Available
RM0030310 	HTL00303	424.01	DOUBLE	City View	t	Available
RM0030311 	HTL00303	452.33	SINGLE	Garden View	t	Available
RM0030312 	HTL00303	337.28	QUAD	Sea View	t	Available
RM0030313 	HTL00303	288.16	QUAD	River View	f	Available
RM0030400 	HTL00304	132.61	QUAD	Sea View	f	Available
RM0030401 	HTL00304	114.25	SUITE	River View	t	Available
RM0030402 	HTL00304	372.09	SUITE	Pool View	t	Available
RM0030403 	HTL00304	173.05	DOUBLE	Garden View	t	Available
RM0030404 	HTL00304	193.24	TRIPLE	Forest View	t	Available
RM0030405 	HTL00304	353.05	TRIPLE	Forest View	t	Available
RM0030406 	HTL00304	403.94	DOUBLE	Garden View	f	Available
RM0030407 	HTL00304	138.60	SINGLE	Mountain View	f	Available
RM0030408 	HTL00304	292.74	SINGLE	Mountain View	f	Available
RM0030409 	HTL00304	465.97	QUAD	Courtyard View	t	Available
RM0030410 	HTL00304	424.16	SUITE	Skyline View	f	Available
RM0030411 	HTL00304	401.88	SINGLE	City View	f	Available
RM0030412 	HTL00304	105.75	DOUBLE	City View	f	Available
RM0030413 	HTL00304	207.89	QUAD	River View	t	Available
RM0030500 	HTL00305	184.87	DOUBLE	Pool View	f	Available
RM0030501 	HTL00305	498.06	QUAD	Skyline View	t	Available
RM0030502 	HTL00305	363.23	SUITE	River View	f	Available
RM0030503 	HTL00305	307.80	QUAD	Garden View	t	Available
RM0030504 	HTL00305	324.49	SUITE	Skyline View	t	Available
RM0030505 	HTL00305	184.09	SINGLE	Lake View	f	Available
RM0030506 	HTL00305	252.90	SUITE	Lake View	t	Available
RM0030507 	HTL00305	245.22	SUITE	Pool View	f	Available
RM0030508 	HTL00305	497.23	DOUBLE	River View	t	Available
RM0030509 	HTL00305	443.48	DOUBLE	Sea View	t	Available
RM0030510 	HTL00305	193.12	SUITE	Mountain View	t	Available
RM0030511 	HTL00305	399.20	DOUBLE	River View	t	Available
RM0030512 	HTL00305	475.60	SINGLE	Skyline View	t	Available
RM0030513 	HTL00305	466.25	SINGLE	River View	t	Available
RM0030600 	HTL00306	455.02	SINGLE	Pool View	f	Available
RM0030601 	HTL00306	443.66	DOUBLE	Mountain View	f	Available
RM0030602 	HTL00306	325.42	TRIPLE	Mountain View	t	Available
RM0030603 	HTL00306	479.17	SINGLE	City View	t	Available
RM0030604 	HTL00306	489.44	SINGLE	Courtyard View	f	Available
RM0030605 	HTL00306	428.88	QUAD	Garden View	f	Available
RM0030606 	HTL00306	369.66	SINGLE	Pool View	t	Available
RM0030607 	HTL00306	392.73	TRIPLE	City View	f	Available
RM0030608 	HTL00306	286.61	DOUBLE	Pool View	f	Available
RM0030609 	HTL00306	288.87	QUAD	Pool View	f	Available
RM0030610 	HTL00306	238.76	QUAD	Mountain View	f	Available
RM0030700 	HTL00307	292.19	SINGLE	Mountain View	f	Available
RM0030701 	HTL00307	154.06	TRIPLE	River View	t	Available
RM0030702 	HTL00307	291.66	QUAD	Courtyard View	t	Available
RM0030703 	HTL00307	455.31	QUAD	Courtyard View	t	Available
RM0030704 	HTL00307	439.43	TRIPLE	Mountain View	t	Available
RM0030705 	HTL00307	307.76	QUAD	River View	t	Available
RM0030706 	HTL00307	415.56	DOUBLE	Pool View	f	Available
RM0030707 	HTL00307	393.54	QUAD	Lake View	t	Available
RM0030708 	HTL00307	106.57	QUAD	Garden View	f	Available
RM0030709 	HTL00307	208.61	TRIPLE	Courtyard View	f	Available
RM0030710 	HTL00307	480.41	SINGLE	River View	f	Available
RM0030711 	HTL00307	424.32	DOUBLE	City View	t	Available
RM0030712 	HTL00307	210.95	SINGLE	City View	f	Available
RM0030713 	HTL00307	146.22	SINGLE	Mountain View	f	Available
RM0030714 	HTL00307	233.15	TRIPLE	Lake View	t	Available
RM0030715 	HTL00307	420.78	SINGLE	Sea View	t	Available
RM0030716 	HTL00307	391.70	SUITE	Sea View	f	Available
RM0030800 	HTL00308	118.75	QUAD	Mountain View	f	Available
RM0030801 	HTL00308	400.64	DOUBLE	Skyline View	t	Available
RM0030802 	HTL00308	391.94	TRIPLE	Sea View	t	Available
RM0030803 	HTL00308	225.90	QUAD	River View	t	Available
RM0030804 	HTL00308	164.49	QUAD	River View	f	Available
RM0030805 	HTL00308	166.37	SINGLE	Forest View	f	Available
RM0030806 	HTL00308	362.82	SUITE	Skyline View	f	Available
RM0030807 	HTL00308	446.05	TRIPLE	Garden View	f	Available
RM0030808 	HTL00308	475.00	SINGLE	Courtyard View	f	Available
RM0030809 	HTL00308	490.60	TRIPLE	City View	t	Available
RM0030810 	HTL00308	206.08	SUITE	Forest View	f	Available
RM0030811 	HTL00308	171.52	SUITE	River View	f	Available
RM0030812 	HTL00308	381.27	SINGLE	City View	f	Available
RM0030813 	HTL00308	354.81	QUAD	Garden View	f	Available
RM0030814 	HTL00308	417.57	SINGLE	Courtyard View	t	Available
RM0030815 	HTL00308	154.07	SINGLE	City View	f	Available
RM0030900 	HTL00309	305.94	DOUBLE	River View	f	Available
RM0030901 	HTL00309	196.32	SINGLE	Forest View	f	Available
RM0030902 	HTL00309	246.60	SINGLE	Skyline View	f	Available
RM0030903 	HTL00309	223.61	QUAD	Courtyard View	f	Available
RM0030904 	HTL00309	192.48	SUITE	Garden View	f	Available
RM0030905 	HTL00309	171.76	QUAD	Courtyard View	f	Available
RM0030906 	HTL00309	441.08	QUAD	City View	f	Available
RM0030907 	HTL00309	385.81	SINGLE	Garden View	f	Available
RM0030908 	HTL00309	183.27	QUAD	Skyline View	t	Available
RM0030909 	HTL00309	306.40	TRIPLE	Skyline View	t	Available
RM0031000 	HTL00310	293.87	QUAD	River View	t	Available
RM0031001 	HTL00310	265.22	SUITE	Mountain View	t	Available
RM0031002 	HTL00310	169.39	DOUBLE	Forest View	f	Available
RM0031003 	HTL00310	144.49	SINGLE	City View	t	Available
RM0031004 	HTL00310	332.62	QUAD	Skyline View	t	Available
RM0031005 	HTL00310	240.12	SUITE	Mountain View	f	Available
RM0031006 	HTL00310	165.17	SINGLE	River View	t	Available
RM0031007 	HTL00310	298.81	SINGLE	Forest View	f	Available
RM0031008 	HTL00310	339.18	TRIPLE	Courtyard View	t	Available
RM0031009 	HTL00310	273.76	SINGLE	Forest View	f	Available
RM0031010 	HTL00310	483.64	QUAD	Garden View	t	Available
RM0031011 	HTL00310	299.13	SUITE	River View	f	Available
RM0031012 	HTL00310	156.93	SINGLE	Pool View	f	Available
RM0031013 	HTL00310	435.69	TRIPLE	Sea View	f	Available
RM0031014 	HTL00310	100.22	QUAD	Pool View	f	Available
RM0031015 	HTL00310	318.05	SUITE	Pool View	t	Available
RM0031016 	HTL00310	426.48	QUAD	Sea View	t	Available
RM0031100 	HTL00311	389.02	TRIPLE	Sea View	f	Available
RM0031101 	HTL00311	296.99	DOUBLE	Mountain View	f	Available
RM0031102 	HTL00311	235.80	QUAD	Garden View	f	Available
RM0031103 	HTL00311	124.32	QUAD	City View	t	Available
RM0031104 	HTL00311	362.10	QUAD	Pool View	t	Available
RM0031105 	HTL00311	131.07	TRIPLE	Forest View	t	Available
RM0031106 	HTL00311	344.26	QUAD	Mountain View	f	Available
RM0031107 	HTL00311	158.38	TRIPLE	Mountain View	f	Available
RM0031108 	HTL00311	183.35	DOUBLE	Courtyard View	f	Available
RM0031109 	HTL00311	163.52	QUAD	Skyline View	t	Available
RM0031110 	HTL00311	227.92	DOUBLE	Garden View	f	Available
RM0031111 	HTL00311	147.46	SUITE	Pool View	f	Available
RM0031112 	HTL00311	114.64	QUAD	River View	t	Available
RM0031113 	HTL00311	471.59	QUAD	Courtyard View	t	Available
RM0031114 	HTL00311	450.24	QUAD	River View	t	Available
RM0031115 	HTL00311	271.75	QUAD	River View	t	Available
RM0031116 	HTL00311	389.48	SUITE	Sea View	f	Available
RM0031117 	HTL00311	195.16	DOUBLE	Sea View	f	Available
RM0031118 	HTL00311	226.14	QUAD	Garden View	f	Available
RM0031200 	HTL00312	129.53	SUITE	Forest View	f	Available
RM0031201 	HTL00312	409.07	SINGLE	Skyline View	f	Available
RM0031202 	HTL00312	385.52	SUITE	River View	f	Available
RM0031203 	HTL00312	150.96	SUITE	City View	t	Available
RM0031204 	HTL00312	247.87	TRIPLE	Mountain View	t	Available
RM0031205 	HTL00312	233.02	TRIPLE	City View	t	Available
RM0031206 	HTL00312	438.22	SUITE	Pool View	t	Available
RM0031207 	HTL00312	306.14	DOUBLE	City View	t	Available
RM0031208 	HTL00312	362.95	TRIPLE	Courtyard View	t	Available
RM0031209 	HTL00312	269.90	SUITE	Sea View	f	Available
RM0031210 	HTL00312	373.72	DOUBLE	River View	f	Available
RM0031211 	HTL00312	236.99	TRIPLE	River View	t	Available
RM0031212 	HTL00312	432.68	QUAD	Lake View	f	Available
RM0031213 	HTL00312	415.83	QUAD	Mountain View	f	Available
RM0031214 	HTL00312	170.53	QUAD	Pool View	t	Available
RM0031215 	HTL00312	237.52	SINGLE	Pool View	f	Available
RM0031216 	HTL00312	144.38	QUAD	Courtyard View	f	Available
RM0031300 	HTL00313	122.43	TRIPLE	Mountain View	f	Available
RM0031301 	HTL00313	319.62	QUAD	Pool View	f	Available
RM0031302 	HTL00313	360.05	DOUBLE	Forest View	t	Available
RM0031303 	HTL00313	312.91	QUAD	Sea View	t	Available
RM0031304 	HTL00313	153.44	SUITE	City View	t	Available
RM0031305 	HTL00313	150.24	SINGLE	Courtyard View	f	Available
RM0031306 	HTL00313	292.79	SINGLE	Courtyard View	f	Available
RM0031307 	HTL00313	134.87	SUITE	Pool View	t	Available
RM0031308 	HTL00313	104.00	TRIPLE	Pool View	t	Available
RM0031309 	HTL00313	121.02	DOUBLE	Mountain View	f	Available
RM0031310 	HTL00313	234.63	QUAD	Courtyard View	t	Available
RM0031311 	HTL00313	161.97	DOUBLE	City View	t	Available
RM0031312 	HTL00313	198.44	DOUBLE	City View	f	Available
RM0031400 	HTL00314	154.94	SINGLE	Courtyard View	f	Available
RM0031401 	HTL00314	403.16	QUAD	Courtyard View	f	Available
RM0031402 	HTL00314	150.01	SUITE	Garden View	t	Available
RM0031403 	HTL00314	289.10	DOUBLE	River View	f	Available
RM0031404 	HTL00314	481.89	QUAD	Skyline View	f	Available
RM0031405 	HTL00314	442.78	QUAD	Sea View	f	Available
RM0031406 	HTL00314	166.56	SINGLE	City View	f	Available
RM0031407 	HTL00314	159.82	TRIPLE	Garden View	t	Available
RM0031408 	HTL00314	230.38	SUITE	Forest View	t	Available
RM0031409 	HTL00314	449.67	DOUBLE	River View	t	Available
RM0031410 	HTL00314	108.19	QUAD	Skyline View	t	Available
RM0031411 	HTL00314	281.80	DOUBLE	River View	f	Available
RM0031412 	HTL00314	384.57	TRIPLE	Sea View	f	Available
RM0031413 	HTL00314	312.96	TRIPLE	Garden View	t	Available
RM0031414 	HTL00314	487.34	QUAD	Lake View	t	Available
RM0031415 	HTL00314	442.30	SINGLE	Garden View	f	Available
RM0031500 	HTL00315	357.58	SINGLE	Garden View	f	Available
RM0031501 	HTL00315	344.74	SINGLE	Forest View	f	Available
RM0031502 	HTL00315	486.16	DOUBLE	Pool View	t	Available
RM0031503 	HTL00315	293.50	QUAD	Lake View	f	Available
RM0031504 	HTL00315	132.30	SUITE	Lake View	f	Available
RM0031505 	HTL00315	316.09	DOUBLE	Garden View	f	Available
RM0031506 	HTL00315	492.76	DOUBLE	Garden View	t	Available
RM0031507 	HTL00315	288.10	QUAD	Sea View	t	Available
RM0031508 	HTL00315	157.55	QUAD	River View	t	Available
RM0031509 	HTL00315	490.14	TRIPLE	Forest View	t	Available
RM0031510 	HTL00315	369.88	DOUBLE	Forest View	f	Available
RM0031511 	HTL00315	248.21	TRIPLE	Sea View	t	Available
RM0031512 	HTL00315	253.55	QUAD	Lake View	t	Available
RM0031513 	HTL00315	300.88	DOUBLE	Lake View	t	Available
RM0031514 	HTL00315	378.33	SUITE	Lake View	f	Available
RM0040000 	HTL00400	174.44	TRIPLE	Garden View	t	Available
RM0040001 	HTL00400	195.43	QUAD	Lake View	f	Available
RM0040002 	HTL00400	222.99	TRIPLE	Mountain View	f	Available
RM0040003 	HTL00400	406.17	SUITE	Sea View	t	Available
RM0040004 	HTL00400	180.43	TRIPLE	Garden View	t	Available
RM0040005 	HTL00400	435.20	SINGLE	Skyline View	t	Available
RM0040006 	HTL00400	219.08	SINGLE	Sea View	t	Available
RM0040007 	HTL00400	346.09	TRIPLE	Forest View	f	Available
RM0040008 	HTL00400	347.92	SINGLE	Pool View	t	Available
RM0040009 	HTL00400	153.14	SINGLE	Pool View	f	Available
RM0040100 	HTL00401	313.15	SINGLE	Sea View	t	Available
RM0040101 	HTL00401	221.76	DOUBLE	Sea View	f	Available
RM0040102 	HTL00401	127.43	QUAD	Forest View	t	Available
RM0040103 	HTL00401	434.21	TRIPLE	City View	t	Available
RM0040104 	HTL00401	106.02	DOUBLE	Pool View	t	Available
RM0040105 	HTL00401	285.47	DOUBLE	Forest View	f	Available
RM0040106 	HTL00401	244.17	QUAD	Pool View	t	Available
RM0040107 	HTL00401	217.23	TRIPLE	City View	t	Available
RM0040108 	HTL00401	453.79	DOUBLE	Forest View	t	Available
RM0040109 	HTL00401	357.73	TRIPLE	Lake View	f	Available
RM0040110 	HTL00401	421.84	DOUBLE	Mountain View	t	Available
RM0040111 	HTL00401	391.64	DOUBLE	Mountain View	t	Available
RM0040112 	HTL00401	231.22	DOUBLE	Courtyard View	f	Available
RM0040113 	HTL00401	348.00	DOUBLE	Garden View	f	Available
RM0040114 	HTL00401	439.62	QUAD	Garden View	t	Available
RM0040115 	HTL00401	474.73	SUITE	Lake View	f	Available
RM0040200 	HTL00402	150.97	DOUBLE	Lake View	f	Available
RM0040201 	HTL00402	308.29	SUITE	City View	f	Available
RM0040202 	HTL00402	156.24	SINGLE	Pool View	f	Available
RM0040203 	HTL00402	480.62	SINGLE	Lake View	f	Available
RM0040204 	HTL00402	205.71	QUAD	Mountain View	t	Available
RM0040205 	HTL00402	238.83	SINGLE	River View	f	Available
RM0040206 	HTL00402	226.63	DOUBLE	Skyline View	f	Available
RM0040207 	HTL00402	165.36	TRIPLE	Forest View	f	Available
RM0040208 	HTL00402	133.80	SINGLE	River View	f	Available
RM0040209 	HTL00402	364.16	SINGLE	Lake View	t	Available
RM0040210 	HTL00402	189.55	SUITE	Skyline View	t	Available
RM0040300 	HTL00403	324.54	DOUBLE	Garden View	f	Available
RM0040301 	HTL00403	415.93	QUAD	Garden View	f	Available
RM0040302 	HTL00403	115.47	TRIPLE	River View	t	Available
RM0040303 	HTL00403	481.80	SUITE	Sea View	t	Available
RM0040304 	HTL00403	286.54	TRIPLE	City View	t	Available
RM0040305 	HTL00403	295.50	TRIPLE	City View	t	Available
RM0040306 	HTL00403	423.71	SINGLE	River View	t	Available
RM0040307 	HTL00403	409.20	DOUBLE	Garden View	f	Available
RM0040308 	HTL00403	378.90	TRIPLE	Skyline View	f	Available
RM0040309 	HTL00403	356.30	SINGLE	Sea View	f	Available
RM0040310 	HTL00403	350.12	QUAD	Garden View	t	Available
RM0040311 	HTL00403	244.70	SUITE	Forest View	f	Available
RM0040400 	HTL00404	108.40	DOUBLE	Mountain View	f	Available
RM0040401 	HTL00404	258.59	TRIPLE	Courtyard View	t	Available
RM0040402 	HTL00404	448.13	DOUBLE	Courtyard View	t	Available
RM0040403 	HTL00404	383.39	QUAD	Lake View	t	Available
RM0040404 	HTL00404	191.49	TRIPLE	River View	t	Available
RM0040405 	HTL00404	480.96	TRIPLE	Mountain View	f	Available
RM0040406 	HTL00404	335.16	TRIPLE	Courtyard View	t	Available
RM0040407 	HTL00404	348.95	TRIPLE	City View	t	Available
RM0040408 	HTL00404	334.45	QUAD	Pool View	t	Available
RM0040409 	HTL00404	232.06	SINGLE	River View	f	Available
RM0040410 	HTL00404	111.22	SUITE	Sea View	t	Available
RM0040411 	HTL00404	488.56	TRIPLE	Mountain View	t	Available
RM0040412 	HTL00404	471.30	SUITE	Lake View	f	Available
RM0040413 	HTL00404	281.96	SUITE	City View	t	Available
RM0040414 	HTL00404	124.89	SUITE	Sea View	f	Available
RM0040415 	HTL00404	417.76	DOUBLE	Courtyard View	t	Available
RM0040416 	HTL00404	159.99	DOUBLE	Skyline View	t	Available
RM0040500 	HTL00405	224.22	QUAD	Forest View	f	Available
RM0040501 	HTL00405	102.40	SUITE	Sea View	t	Available
RM0040502 	HTL00405	206.02	SINGLE	River View	t	Available
RM0040503 	HTL00405	374.87	SUITE	Mountain View	f	Available
RM0040504 	HTL00405	300.65	TRIPLE	Courtyard View	f	Available
RM0040505 	HTL00405	431.01	SUITE	River View	t	Available
RM0040506 	HTL00405	325.93	TRIPLE	Courtyard View	t	Available
RM0040507 	HTL00405	413.66	TRIPLE	City View	f	Available
RM0040508 	HTL00405	247.57	SINGLE	Courtyard View	f	Available
RM0040509 	HTL00405	142.48	SINGLE	Lake View	f	Available
RM0040510 	HTL00405	128.41	SINGLE	Forest View	f	Available
RM0040511 	HTL00405	222.47	SUITE	Mountain View	f	Available
RM0040512 	HTL00405	250.52	QUAD	Mountain View	t	Available
RM0040513 	HTL00405	350.53	QUAD	Sea View	f	Available
RM0040514 	HTL00405	346.19	SUITE	Sea View	t	Available
RM0040515 	HTL00405	366.61	SINGLE	Pool View	f	Available
RM0040516 	HTL00405	193.49	QUAD	Forest View	t	Available
RM0040600 	HTL00406	309.70	DOUBLE	Sea View	t	Available
RM0040601 	HTL00406	106.33	SINGLE	Garden View	f	Available
RM0040602 	HTL00406	329.39	SINGLE	Courtyard View	f	Available
RM0040603 	HTL00406	150.17	SINGLE	City View	f	Available
RM0040604 	HTL00406	317.55	QUAD	Lake View	f	Available
RM0040605 	HTL00406	267.61	SUITE	City View	f	Available
RM0040606 	HTL00406	399.50	QUAD	River View	t	Available
RM0040607 	HTL00406	217.56	SINGLE	Lake View	t	Available
RM0040608 	HTL00406	494.29	DOUBLE	River View	t	Available
RM0040609 	HTL00406	196.40	TRIPLE	Courtyard View	f	Available
RM0040610 	HTL00406	342.97	SUITE	River View	f	Available
RM0040611 	HTL00406	410.14	DOUBLE	Pool View	t	Available
RM0040612 	HTL00406	404.48	DOUBLE	Garden View	f	Available
RM0040613 	HTL00406	374.84	TRIPLE	City View	f	Available
RM0040614 	HTL00406	253.72	SINGLE	Skyline View	t	Available
RM0040615 	HTL00406	425.57	SUITE	Sea View	f	Available
RM0040700 	HTL00407	133.90	SINGLE	Forest View	f	Available
RM0040701 	HTL00407	143.41	SUITE	Courtyard View	f	Available
RM0040702 	HTL00407	219.38	QUAD	Pool View	t	Available
RM0040703 	HTL00407	215.85	TRIPLE	Pool View	t	Available
RM0040704 	HTL00407	193.85	SINGLE	Forest View	f	Available
RM0040705 	HTL00407	302.70	QUAD	Forest View	f	Available
RM0040706 	HTL00407	425.78	SINGLE	Pool View	t	Available
RM0040707 	HTL00407	376.24	SINGLE	Pool View	f	Available
RM0040708 	HTL00407	117.52	SUITE	Skyline View	f	Available
RM0040709 	HTL00407	402.76	DOUBLE	Mountain View	f	Available
RM0040710 	HTL00407	350.51	SINGLE	Garden View	f	Available
RM0040711 	HTL00407	424.06	SUITE	Skyline View	t	Available
RM0040712 	HTL00407	404.99	QUAD	Courtyard View	f	Available
RM0040713 	HTL00407	261.36	DOUBLE	Courtyard View	f	Available
RM0040714 	HTL00407	479.28	QUAD	Pool View	f	Available
RM0040800 	HTL00408	221.32	QUAD	Forest View	t	Available
RM0040801 	HTL00408	325.70	DOUBLE	Lake View	t	Available
RM0040802 	HTL00408	418.37	TRIPLE	Mountain View	t	Available
RM0040803 	HTL00408	117.93	QUAD	Mountain View	t	Available
RM0040804 	HTL00408	336.62	DOUBLE	Forest View	f	Available
RM0040805 	HTL00408	215.10	QUAD	Courtyard View	t	Available
RM0040806 	HTL00408	467.29	SINGLE	Garden View	f	Available
RM0040807 	HTL00408	168.29	DOUBLE	Sea View	f	Available
RM0040808 	HTL00408	184.84	SUITE	Sea View	t	Available
RM0040809 	HTL00408	330.67	DOUBLE	Sea View	t	Available
RM0040810 	HTL00408	234.08	SUITE	Sea View	t	Available
RM0040811 	HTL00408	307.03	SINGLE	Lake View	f	Available
RM0040900 	HTL00409	392.36	TRIPLE	Garden View	f	Available
RM0040901 	HTL00409	323.26	QUAD	River View	t	Available
RM0040902 	HTL00409	211.92	TRIPLE	Courtyard View	t	Available
RM0040903 	HTL00409	190.63	SUITE	Lake View	f	Available
RM0040904 	HTL00409	314.47	SUITE	Pool View	t	Available
RM0040905 	HTL00409	375.71	SUITE	Lake View	f	Available
RM0040906 	HTL00409	427.16	TRIPLE	Sea View	t	Available
RM0040907 	HTL00409	372.05	SUITE	City View	t	Available
RM0040908 	HTL00409	289.39	SINGLE	Lake View	t	Available
RM0040909 	HTL00409	436.07	SINGLE	Lake View	f	Available
RM0040910 	HTL00409	180.18	QUAD	Courtyard View	t	Available
RM0041000 	HTL00410	431.06	SINGLE	Pool View	t	Available
RM0041001 	HTL00410	182.32	DOUBLE	Courtyard View	t	Available
RM0041002 	HTL00410	133.08	SUITE	Pool View	t	Available
RM0041003 	HTL00410	103.92	DOUBLE	Forest View	t	Available
RM0041004 	HTL00410	390.38	DOUBLE	Lake View	t	Available
RM0041005 	HTL00410	150.49	DOUBLE	Skyline View	t	Available
RM0041006 	HTL00410	314.54	TRIPLE	River View	f	Available
RM0041007 	HTL00410	203.46	SINGLE	Forest View	t	Available
RM0041008 	HTL00410	289.75	SUITE	City View	f	Available
RM0041009 	HTL00410	204.37	TRIPLE	Courtyard View	t	Available
RM0041010 	HTL00410	130.76	SINGLE	Courtyard View	t	Available
RM0041011 	HTL00410	117.63	DOUBLE	Mountain View	f	Available
RM0041012 	HTL00410	104.99	QUAD	Lake View	f	Available
RM0041013 	HTL00410	156.29	QUAD	Sea View	t	Available
RM0041014 	HTL00410	183.60	SINGLE	Courtyard View	f	Available
RM0041100 	HTL00411	149.62	SINGLE	Skyline View	f	Available
RM0041101 	HTL00411	126.08	TRIPLE	River View	f	Available
RM0041102 	HTL00411	447.65	DOUBLE	Lake View	t	Available
RM0041103 	HTL00411	416.16	DOUBLE	Forest View	f	Available
RM0041104 	HTL00411	397.72	QUAD	Courtyard View	f	Available
RM0041105 	HTL00411	116.88	SINGLE	Pool View	f	Available
RM0041106 	HTL00411	377.64	QUAD	Garden View	t	Available
RM0041107 	HTL00411	429.49	DOUBLE	Lake View	f	Available
RM0041108 	HTL00411	223.41	QUAD	Courtyard View	f	Available
RM0041109 	HTL00411	143.70	SINGLE	Lake View	t	Available
RM0041110 	HTL00411	147.46	DOUBLE	Lake View	f	Available
RM0041111 	HTL00411	458.09	DOUBLE	Garden View	f	Available
RM0041112 	HTL00411	442.71	SUITE	Pool View	t	Available
RM0041113 	HTL00411	226.16	QUAD	River View	t	Available
RM0041114 	HTL00411	114.13	SUITE	Sea View	f	Available
RM0041200 	HTL00412	377.45	QUAD	Sea View	t	Available
RM0041201 	HTL00412	475.77	TRIPLE	Garden View	f	Available
RM0041202 	HTL00412	169.23	SUITE	Sea View	f	Available
RM0041203 	HTL00412	454.24	QUAD	Sea View	f	Available
RM0041204 	HTL00412	246.51	SINGLE	River View	t	Available
RM0041205 	HTL00412	197.73	SINGLE	Mountain View	t	Available
RM0041206 	HTL00412	338.99	QUAD	Sea View	t	Available
RM0041207 	HTL00412	349.13	SUITE	Mountain View	t	Available
RM0041208 	HTL00412	313.31	QUAD	Skyline View	f	Available
RM0041209 	HTL00412	407.77	DOUBLE	City View	f	Available
RM0041300 	HTL00413	419.32	SUITE	Garden View	f	Available
RM0041301 	HTL00413	253.98	QUAD	Lake View	t	Available
RM0041302 	HTL00413	435.42	QUAD	Forest View	t	Available
RM0041303 	HTL00413	375.37	TRIPLE	Skyline View	f	Available
RM0041304 	HTL00413	206.47	SUITE	Lake View	f	Available
RM0041305 	HTL00413	202.49	SINGLE	Courtyard View	t	Available
RM0041306 	HTL00413	494.67	SUITE	Sea View	t	Available
RM0041307 	HTL00413	368.83	QUAD	Forest View	f	Available
RM0041308 	HTL00413	294.37	SINGLE	Skyline View	t	Available
RM0041309 	HTL00413	339.52	QUAD	Courtyard View	t	Available
RM0041310 	HTL00413	238.96	SUITE	Sea View	t	Available
RM0041311 	HTL00413	204.33	TRIPLE	Lake View	t	Available
RM0041312 	HTL00413	354.86	SINGLE	Courtyard View	f	Available
RM0041313 	HTL00413	171.27	QUAD	Courtyard View	t	Available
RM0041314 	HTL00413	462.80	TRIPLE	City View	t	Available
RM0041315 	HTL00413	297.50	SINGLE	Skyline View	t	Available
RM0041400 	HTL00414	135.70	SINGLE	Courtyard View	t	Available
RM0041401 	HTL00414	226.94	DOUBLE	Mountain View	t	Available
RM0041402 	HTL00414	200.48	SINGLE	Sea View	t	Available
RM0041403 	HTL00414	343.09	SUITE	River View	f	Available
RM0041404 	HTL00414	372.34	TRIPLE	City View	f	Available
RM0041405 	HTL00414	290.54	QUAD	Garden View	f	Available
RM0041406 	HTL00414	435.98	SUITE	River View	f	Available
RM0041407 	HTL00414	272.03	SUITE	Sea View	t	Available
RM0041408 	HTL00414	152.66	TRIPLE	Garden View	t	Available
RM0041409 	HTL00414	360.40	SINGLE	Mountain View	f	Available
RM0041500 	HTL00415	272.89	DOUBLE	Pool View	t	Available
RM0041501 	HTL00415	289.27	SUITE	City View	f	Available
RM0041502 	HTL00415	286.56	TRIPLE	Lake View	t	Available
RM0041503 	HTL00415	487.30	DOUBLE	Pool View	t	Available
RM0041504 	HTL00415	177.21	SUITE	Courtyard View	f	Available
RM0041505 	HTL00415	328.61	TRIPLE	Garden View	f	Available
RM0041506 	HTL00415	274.36	QUAD	Mountain View	f	Available
RM0041507 	HTL00415	178.92	QUAD	Courtyard View	t	Available
RM0041508 	HTL00415	271.32	SUITE	Mountain View	t	Available
RM0041509 	HTL00415	264.77	DOUBLE	Pool View	f	Available
RM0041510 	HTL00415	450.67	SUITE	Courtyard View	f	Available
RM0041511 	HTL00415	352.07	TRIPLE	River View	t	Available
RM0041600 	HTL00416	195.63	SUITE	Skyline View	f	Available
RM0041601 	HTL00416	247.78	SUITE	Sea View	f	Available
RM0041602 	HTL00416	467.68	SINGLE	Pool View	f	Available
RM0041603 	HTL00416	130.32	SINGLE	Skyline View	f	Available
RM0041604 	HTL00416	266.61	DOUBLE	Pool View	t	Available
RM0041605 	HTL00416	494.10	SUITE	Mountain View	f	Available
RM0041606 	HTL00416	300.40	SINGLE	River View	t	Available
RM0041607 	HTL00416	183.80	SUITE	Pool View	f	Available
RM0041608 	HTL00416	283.75	QUAD	Garden View	t	Available
RM0041609 	HTL00416	301.77	QUAD	Lake View	f	Available
RM0041610 	HTL00416	469.93	QUAD	Forest View	t	Available
RM0041611 	HTL00416	310.11	SUITE	Garden View	f	Available
RM0041612 	HTL00416	151.91	DOUBLE	Courtyard View	f	Available
RM0041613 	HTL00416	464.28	QUAD	Lake View	t	Available
RM0041614 	HTL00416	180.64	SINGLE	Garden View	f	Available
RM0041615 	HTL00416	128.18	DOUBLE	Forest View	f	Available
RM0041616 	HTL00416	432.52	TRIPLE	Courtyard View	t	Available
RM0041617 	HTL00416	113.57	SINGLE	Courtyard View	t	Available
RM0041618 	HTL00416	248.64	SINGLE	Pool View	f	Available
RM0041700 	HTL00417	486.98	SINGLE	Lake View	f	Available
RM0041701 	HTL00417	439.42	DOUBLE	Mountain View	f	Available
RM0041702 	HTL00417	469.49	TRIPLE	City View	f	Available
RM0041703 	HTL00417	252.52	SINGLE	River View	f	Available
RM0041704 	HTL00417	151.97	DOUBLE	Courtyard View	f	Available
RM0041705 	HTL00417	133.81	SUITE	Courtyard View	t	Available
RM0041706 	HTL00417	241.16	SINGLE	Garden View	t	Available
RM0041707 	HTL00417	198.05	SUITE	Skyline View	f	Available
RM0041708 	HTL00417	256.12	QUAD	Mountain View	f	Available
RM0041709 	HTL00417	224.05	TRIPLE	Lake View	t	Available
RM0041710 	HTL00417	429.24	DOUBLE	Forest View	t	Available
RM0041711 	HTL00417	417.07	DOUBLE	Lake View	f	Available
RM0041712 	HTL00417	284.84	QUAD	Garden View	f	Available
RM0041713 	HTL00417	293.19	QUAD	River View	t	Available
RM0041714 	HTL00417	405.12	TRIPLE	Mountain View	t	Available
RM0041715 	HTL00417	137.52	QUAD	Garden View	t	Available
RM0041716 	HTL00417	392.66	DOUBLE	Garden View	t	Available
RM0041717 	HTL00417	444.17	DOUBLE	City View	f	Available
RM0041718 	HTL00417	413.31	SINGLE	Garden View	f	Available
RM0041719 	HTL00417	386.50	DOUBLE	Sea View	f	Available
RM0041800 	HTL00418	367.10	SUITE	Forest View	t	Available
RM0041801 	HTL00418	475.09	TRIPLE	Garden View	t	Available
RM0041802 	HTL00418	474.77	QUAD	Sea View	t	Available
RM0041803 	HTL00418	312.04	QUAD	Forest View	f	Available
RM0041804 	HTL00418	443.04	SINGLE	City View	f	Available
RM0041805 	HTL00418	292.91	SINGLE	Mountain View	t	Available
RM0041806 	HTL00418	269.60	SUITE	Garden View	t	Available
RM0041807 	HTL00418	466.97	SUITE	Forest View	t	Available
RM0041808 	HTL00418	363.49	SUITE	Sea View	t	Available
RM0041809 	HTL00418	291.20	SINGLE	Mountain View	f	Available
RM0041810 	HTL00418	212.16	SINGLE	Lake View	t	Available
RM0041811 	HTL00418	310.43	QUAD	Courtyard View	t	Available
RM0041812 	HTL00418	163.96	QUAD	Pool View	t	Available
RM0041813 	HTL00418	183.84	QUAD	Courtyard View	f	Available
RM0041814 	HTL00418	316.83	QUAD	Forest View	t	Available
RM0041815 	HTL00418	292.29	SUITE	Pool View	f	Available
RM0041816 	HTL00418	129.41	TRIPLE	Lake View	f	Available
RM0041817 	HTL00418	191.07	DOUBLE	River View	f	Available
RM0041900 	HTL00419	116.53	DOUBLE	Garden View	t	Available
RM0041901 	HTL00419	334.30	SINGLE	Skyline View	t	Available
RM0041902 	HTL00419	132.51	QUAD	Pool View	f	Available
RM0041903 	HTL00419	251.78	DOUBLE	Courtyard View	t	Available
RM0041904 	HTL00419	406.15	DOUBLE	Garden View	t	Available
RM0041905 	HTL00419	286.65	SINGLE	Forest View	f	Available
RM0041906 	HTL00419	255.73	QUAD	Pool View	t	Available
RM0041907 	HTL00419	101.07	SINGLE	Lake View	f	Available
RM0041908 	HTL00419	150.53	QUAD	Skyline View	t	Available
RM0041909 	HTL00419	469.17	QUAD	River View	f	Available
RM0041910 	HTL00419	410.16	QUAD	Forest View	t	Available
RM0041911 	HTL00419	437.99	QUAD	Forest View	t	Available
RM0041912 	HTL00419	164.85	QUAD	Garden View	t	Available
RM0041913 	HTL00419	255.47	SUITE	Courtyard View	f	Available
RM0041914 	HTL00419	423.18	SINGLE	Skyline View	t	Available
RM0041915 	HTL00419	496.32	TRIPLE	Forest View	f	Available
RM0041916 	HTL00419	394.83	DOUBLE	Lake View	f	Available
RM0041917 	HTL00419	400.03	SUITE	Mountain View	f	Available
RM0050000 	HTL00500	174.44	DOUBLE	Forest View	f	Available
RM0050001 	HTL00500	195.57	QUAD	Mountain View	f	Available
RM0050002 	HTL00500	252.98	SUITE	Skyline View	t	Available
RM0050003 	HTL00500	171.63	SINGLE	River View	t	Available
RM0050004 	HTL00500	397.01	SUITE	Garden View	t	Available
RM0050005 	HTL00500	231.21	SUITE	Garden View	f	Available
RM0050006 	HTL00500	335.26	DOUBLE	Mountain View	t	Available
RM0050007 	HTL00500	169.38	DOUBLE	Mountain View	f	Available
RM0050008 	HTL00500	104.24	DOUBLE	Garden View	t	Available
RM0050009 	HTL00500	287.10	QUAD	Lake View	f	Available
RM0050010 	HTL00500	192.10	TRIPLE	Mountain View	f	Available
RM0050011 	HTL00500	224.48	DOUBLE	Mountain View	t	Available
RM0050012 	HTL00500	387.48	SUITE	Sea View	t	Available
RM0050013 	HTL00500	283.43	SINGLE	River View	t	Available
RM0050100 	HTL00501	251.03	DOUBLE	Garden View	f	Available
RM0050101 	HTL00501	154.69	SINGLE	Skyline View	t	Available
RM0050102 	HTL00501	168.70	SUITE	Skyline View	f	Available
RM0050103 	HTL00501	167.08	QUAD	Sea View	t	Available
RM0050104 	HTL00501	206.98	QUAD	Garden View	f	Available
RM0050105 	HTL00501	257.01	SINGLE	River View	f	Available
RM0050106 	HTL00501	125.81	SUITE	City View	t	Available
RM0050107 	HTL00501	164.72	TRIPLE	Skyline View	t	Available
RM0050108 	HTL00501	495.37	QUAD	Skyline View	f	Available
RM0050109 	HTL00501	450.80	SINGLE	Sea View	t	Available
RM0050110 	HTL00501	179.66	SINGLE	Lake View	t	Available
RM0050111 	HTL00501	109.01	DOUBLE	Pool View	f	Available
RM0050112 	HTL00501	383.93	SINGLE	Lake View	t	Available
RM0050113 	HTL00501	370.57	SINGLE	Forest View	f	Available
RM0050114 	HTL00501	389.03	TRIPLE	Courtyard View	f	Available
RM0050115 	HTL00501	327.33	SUITE	Courtyard View	f	Available
RM0050116 	HTL00501	268.08	QUAD	Garden View	t	Available
RM0050117 	HTL00501	327.79	SINGLE	Forest View	f	Available
RM0050200 	HTL00502	150.12	DOUBLE	Garden View	f	Available
RM0050201 	HTL00502	148.10	SUITE	Garden View	t	Available
RM0050202 	HTL00502	494.50	SINGLE	Sea View	t	Available
RM0050203 	HTL00502	261.08	SUITE	Garden View	t	Available
RM0050204 	HTL00502	259.69	DOUBLE	Forest View	t	Available
RM0050205 	HTL00502	194.44	QUAD	Sea View	f	Available
RM0050206 	HTL00502	321.71	DOUBLE	River View	f	Available
RM0050207 	HTL00502	122.65	DOUBLE	Forest View	f	Available
RM0050208 	HTL00502	295.98	SINGLE	Pool View	f	Available
RM0050209 	HTL00502	359.23	SINGLE	Courtyard View	f	Available
RM0050210 	HTL00502	346.51	DOUBLE	Skyline View	f	Available
RM0050300 	HTL00503	428.54	QUAD	Sea View	f	Available
RM0050301 	HTL00503	441.73	TRIPLE	Mountain View	f	Available
RM0050302 	HTL00503	135.10	SINGLE	Mountain View	t	Available
RM0050303 	HTL00503	359.61	QUAD	Courtyard View	t	Available
RM0050304 	HTL00503	419.66	SINGLE	City View	t	Available
RM0050305 	HTL00503	208.36	QUAD	Forest View	t	Available
RM0050306 	HTL00503	374.69	SUITE	City View	f	Available
RM0050307 	HTL00503	290.84	TRIPLE	Courtyard View	t	Available
RM0050308 	HTL00503	122.27	SINGLE	City View	f	Available
RM0050309 	HTL00503	367.43	DOUBLE	Lake View	t	Available
RM0050310 	HTL00503	330.87	DOUBLE	Courtyard View	f	Available
RM0050311 	HTL00503	323.49	SUITE	Forest View	t	Available
RM0050312 	HTL00503	349.52	TRIPLE	Sea View	t	Available
RM0050400 	HTL00504	118.65	QUAD	City View	t	Available
RM0050401 	HTL00504	272.07	SUITE	River View	f	Available
RM0050402 	HTL00504	474.37	QUAD	City View	t	Available
RM0050403 	HTL00504	372.04	QUAD	Garden View	f	Available
RM0050404 	HTL00504	439.20	TRIPLE	River View	f	Available
RM0050405 	HTL00504	471.74	QUAD	River View	t	Available
RM0050406 	HTL00504	125.33	SUITE	Courtyard View	f	Available
RM0050407 	HTL00504	348.18	SINGLE	Garden View	t	Available
RM0050408 	HTL00504	498.54	TRIPLE	Skyline View	t	Available
RM0050409 	HTL00504	386.77	DOUBLE	Courtyard View	t	Available
RM0050410 	HTL00504	166.93	TRIPLE	Forest View	f	Available
RM0050411 	HTL00504	223.55	QUAD	Skyline View	t	Available
RM0050412 	HTL00504	412.85	QUAD	Skyline View	t	Available
RM0050413 	HTL00504	113.52	SUITE	Forest View	f	Available
RM0050500 	HTL00505	162.82	DOUBLE	Skyline View	f	Available
RM0050501 	HTL00505	186.14	QUAD	Garden View	f	Available
RM0050502 	HTL00505	192.31	DOUBLE	Courtyard View	f	Available
RM0050503 	HTL00505	318.98	SUITE	Forest View	t	Available
RM0050504 	HTL00505	464.72	SINGLE	River View	t	Available
RM0050505 	HTL00505	438.65	SUITE	Garden View	f	Available
RM0050506 	HTL00505	263.46	SUITE	Lake View	t	Available
RM0050507 	HTL00505	317.17	SUITE	City View	f	Available
RM0050508 	HTL00505	379.70	SUITE	Skyline View	t	Available
RM0050509 	HTL00505	210.49	DOUBLE	Pool View	f	Available
RM0050600 	HTL00506	435.40	TRIPLE	Forest View	t	Available
RM0050601 	HTL00506	285.52	TRIPLE	City View	f	Available
RM0050602 	HTL00506	294.39	SINGLE	Mountain View	t	Available
RM0050603 	HTL00506	376.05	SINGLE	Lake View	t	Available
RM0050604 	HTL00506	452.62	SUITE	Garden View	f	Available
RM0050605 	HTL00506	492.65	SUITE	Pool View	f	Available
RM0050606 	HTL00506	173.94	DOUBLE	City View	f	Available
RM0050607 	HTL00506	132.75	QUAD	Forest View	t	Available
RM0050608 	HTL00506	275.04	QUAD	Sea View	t	Available
RM0050609 	HTL00506	145.32	TRIPLE	Sea View	t	Available
RM0050610 	HTL00506	269.09	TRIPLE	Lake View	t	Available
RM0050611 	HTL00506	413.91	SUITE	Mountain View	t	Available
RM0050612 	HTL00506	348.05	SINGLE	Pool View	f	Available
RM0050613 	HTL00506	347.16	SUITE	Sea View	t	Available
RM0050614 	HTL00506	394.86	SUITE	Mountain View	f	Available
RM0050700 	HTL00507	448.87	SINGLE	Sea View	f	Available
RM0050701 	HTL00507	329.57	SINGLE	Sea View	t	Available
RM0050702 	HTL00507	225.44	QUAD	Garden View	f	Available
RM0050703 	HTL00507	103.97	SINGLE	Forest View	f	Available
RM0050704 	HTL00507	282.66	SINGLE	Mountain View	f	Available
RM0050705 	HTL00507	459.98	SUITE	Lake View	t	Available
RM0050706 	HTL00507	156.11	TRIPLE	Garden View	f	Available
RM0050707 	HTL00507	221.07	QUAD	Mountain View	t	Available
RM0050708 	HTL00507	445.68	TRIPLE	Pool View	t	Available
RM0050709 	HTL00507	128.14	TRIPLE	Courtyard View	t	Available
RM0050710 	HTL00507	359.73	TRIPLE	Skyline View	t	Available
RM0050711 	HTL00507	320.41	SUITE	Mountain View	f	Available
RM0050712 	HTL00507	306.93	QUAD	Mountain View	t	Available
RM0050713 	HTL00507	160.68	DOUBLE	Skyline View	f	Available
RM0050714 	HTL00507	158.72	TRIPLE	Pool View	t	Available
RM0050715 	HTL00507	116.53	QUAD	Skyline View	t	Available
RM0050716 	HTL00507	268.04	SUITE	Forest View	f	Available
RM0050717 	HTL00507	143.13	SINGLE	Garden View	f	Available
RM0050718 	HTL00507	373.06	SUITE	Courtyard View	f	Available
RM0050800 	HTL00508	301.75	SUITE	Courtyard View	f	Available
RM0050801 	HTL00508	161.88	SINGLE	Mountain View	f	Available
RM0050802 	HTL00508	329.80	SINGLE	Sea View	t	Available
RM0050803 	HTL00508	338.99	DOUBLE	Skyline View	f	Available
RM0050804 	HTL00508	323.98	SINGLE	Forest View	t	Available
RM0050805 	HTL00508	144.25	QUAD	Garden View	t	Available
RM0050806 	HTL00508	312.39	SINGLE	Pool View	f	Available
RM0050807 	HTL00508	162.33	DOUBLE	Lake View	f	Available
RM0050808 	HTL00508	433.68	SUITE	Pool View	t	Available
RM0050809 	HTL00508	374.93	QUAD	Courtyard View	f	Available
RM0050810 	HTL00508	301.15	SINGLE	Courtyard View	t	Available
RM0050811 	HTL00508	289.31	DOUBLE	Mountain View	f	Available
RM0050812 	HTL00508	229.77	TRIPLE	Pool View	t	Available
RM0050813 	HTL00508	265.50	QUAD	Forest View	t	Available
RM0050814 	HTL00508	215.65	TRIPLE	Pool View	t	Available
RM0050815 	HTL00508	459.44	TRIPLE	Forest View	t	Available
RM0050816 	HTL00508	162.00	TRIPLE	Mountain View	t	Available
RM0050817 	HTL00508	321.08	QUAD	Skyline View	f	Available
RM0050900 	HTL00509	430.52	SUITE	Forest View	t	Available
RM0050901 	HTL00509	491.78	SUITE	City View	f	Available
RM0050902 	HTL00509	381.94	SUITE	Mountain View	f	Available
RM0050903 	HTL00509	435.85	SINGLE	Pool View	f	Available
RM0050904 	HTL00509	317.54	DOUBLE	Pool View	t	Available
RM0050905 	HTL00509	328.71	QUAD	Garden View	t	Available
RM0050906 	HTL00509	292.29	SUITE	Lake View	t	Available
RM0050907 	HTL00509	244.95	TRIPLE	River View	f	Available
RM0050908 	HTL00509	348.57	SUITE	Lake View	f	Available
RM0050909 	HTL00509	218.68	SUITE	City View	t	Available
RM0050910 	HTL00509	249.62	TRIPLE	Mountain View	f	Available
RM0050911 	HTL00509	428.86	SUITE	Sea View	t	Available
RM0050912 	HTL00509	386.38	SUITE	Courtyard View	t	Available
RM0050913 	HTL00509	136.91	DOUBLE	Mountain View	t	Available
RM0050914 	HTL00509	104.05	DOUBLE	Sea View	t	Available
RM0050915 	HTL00509	445.79	TRIPLE	Mountain View	f	Available
RM0050916 	HTL00509	227.97	SINGLE	Lake View	t	Available
RM0050917 	HTL00509	412.40	TRIPLE	Lake View	f	Available
RM0050918 	HTL00509	458.15	TRIPLE	City View	t	Available
RM0051000 	HTL00510	425.74	QUAD	Courtyard View	t	Available
RM0051001 	HTL00510	317.49	DOUBLE	Mountain View	t	Available
RM0051002 	HTL00510	223.16	DOUBLE	River View	t	Available
RM0051003 	HTL00510	415.21	QUAD	Skyline View	t	Available
RM0051004 	HTL00510	484.86	TRIPLE	Lake View	f	Available
RM0051005 	HTL00510	420.09	QUAD	Courtyard View	f	Available
RM0051006 	HTL00510	456.95	DOUBLE	Lake View	t	Available
RM0051007 	HTL00510	240.92	SINGLE	City View	f	Available
RM0051008 	HTL00510	387.66	TRIPLE	City View	f	Available
RM0051009 	HTL00510	279.49	SUITE	Pool View	f	Available
RM0051010 	HTL00510	105.65	SINGLE	Mountain View	t	Available
RM0051011 	HTL00510	329.74	SUITE	Mountain View	t	Available
RM0051012 	HTL00510	347.93	DOUBLE	Pool View	f	Available
RM0051013 	HTL00510	443.17	DOUBLE	Skyline View	t	Available
RM0051014 	HTL00510	238.32	QUAD	City View	f	Available
RM0051015 	HTL00510	491.61	SINGLE	Lake View	t	Available
RM0051100 	HTL00511	454.21	SINGLE	Forest View	t	Available
RM0051101 	HTL00511	155.64	SINGLE	Courtyard View	f	Available
RM0051102 	HTL00511	103.14	TRIPLE	Pool View	t	Available
RM0051103 	HTL00511	380.46	SINGLE	River View	f	Available
RM0051104 	HTL00511	182.28	SINGLE	Courtyard View	t	Available
RM0051105 	HTL00511	443.02	DOUBLE	Mountain View	t	Available
RM0051106 	HTL00511	210.62	QUAD	River View	f	Available
RM0051107 	HTL00511	470.12	QUAD	Forest View	f	Available
RM0051108 	HTL00511	123.65	SUITE	Forest View	t	Available
RM0051109 	HTL00511	149.08	QUAD	Sea View	t	Available
RM0051110 	HTL00511	161.62	QUAD	City View	t	Available
RM0051111 	HTL00511	327.26	SINGLE	Pool View	t	Available
RM0051200 	HTL00512	461.85	SINGLE	Lake View	t	Available
RM0051201 	HTL00512	126.79	TRIPLE	Skyline View	t	Available
RM0051202 	HTL00512	229.04	TRIPLE	Courtyard View	f	Available
RM0051203 	HTL00512	417.74	TRIPLE	Sea View	f	Available
RM0051204 	HTL00512	359.69	SINGLE	Sea View	t	Available
RM0051205 	HTL00512	245.20	QUAD	River View	t	Available
RM0051206 	HTL00512	251.52	QUAD	Skyline View	t	Available
RM0051207 	HTL00512	448.60	TRIPLE	River View	t	Available
RM0051208 	HTL00512	388.69	QUAD	Courtyard View	t	Available
RM0051209 	HTL00512	249.97	DOUBLE	Sea View	f	Available
RM0051210 	HTL00512	351.00	TRIPLE	City View	t	Available
RM0051211 	HTL00512	236.41	DOUBLE	Pool View	f	Available
RM0051212 	HTL00512	116.33	SINGLE	Sea View	f	Available
RM0051213 	HTL00512	339.90	QUAD	Garden View	f	Available
RM0051214 	HTL00512	224.83	SUITE	Lake View	t	Available
RM0051215 	HTL00512	102.80	SINGLE	Pool View	t	Available
RM0051300 	HTL00513	142.89	DOUBLE	Garden View	t	Available
RM0051301 	HTL00513	306.81	QUAD	Pool View	t	Available
RM0051302 	HTL00513	440.19	DOUBLE	Forest View	t	Available
RM0051303 	HTL00513	380.16	TRIPLE	City View	t	Available
RM0051304 	HTL00513	450.11	QUAD	Skyline View	t	Available
RM0051305 	HTL00513	221.20	DOUBLE	Garden View	t	Available
RM0051306 	HTL00513	483.86	QUAD	City View	t	Available
RM0051307 	HTL00513	283.38	QUAD	Lake View	t	Available
RM0051308 	HTL00513	142.98	DOUBLE	Garden View	t	Available
RM0051309 	HTL00513	218.43	SINGLE	Mountain View	t	Available
RM0051310 	HTL00513	131.73	DOUBLE	City View	f	Available
RM0051400 	HTL00514	241.35	SINGLE	Garden View	t	Available
RM0051401 	HTL00514	448.46	QUAD	Lake View	f	Available
RM0051402 	HTL00514	260.65	TRIPLE	Lake View	t	Available
RM0051403 	HTL00514	446.97	TRIPLE	Forest View	f	Available
RM0051404 	HTL00514	467.21	QUAD	Pool View	t	Available
RM0051405 	HTL00514	199.96	QUAD	Sea View	t	Available
RM0051406 	HTL00514	125.23	SUITE	Garden View	t	Available
RM0051407 	HTL00514	421.88	SUITE	Forest View	t	Available
RM0051408 	HTL00514	487.36	QUAD	City View	t	Available
RM0051409 	HTL00514	153.36	SINGLE	Pool View	f	Available
RM0051410 	HTL00514	390.59	QUAD	Lake View	f	Available
RM0051411 	HTL00514	143.03	DOUBLE	Garden View	t	Available
RM0051412 	HTL00514	457.30	TRIPLE	River View	f	Available
RM0051413 	HTL00514	196.29	SINGLE	Skyline View	t	Available
RM0051414 	HTL00514	279.15	QUAD	Skyline View	f	Available
RM0051415 	HTL00514	249.09	QUAD	River View	f	Available
\.


--
-- TOC entry 3768 (class 0 OID 16901)
-- Dependencies: 225
-- Data for Name: roomamenity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roomamenity (room_id, amenity) FROM stdin;
RM0010000 	WIFI
RM0010000 	HAIRDRYER
RM0010000 	IRON
RM0010000 	SAFE
RM0010000 	MINIBAR
RM0010000 	DESK
RM0010000 	TV
RM0010000 	AIR_CONDITION
RM0010000 	COFFEE_MAKER
RM0010000 	FRIDGE
RM0010001 	FRIDGE
RM0010001 	COFFEE_MAKER
RM0010001 	DESK
RM0010001 	WIFI
RM0010001 	IRON
RM0010001 	SAFE
RM0010001 	MICROWAVE
RM0010001 	AIR_CONDITION
RM0010001 	HAIRDRYER
RM0010001 	MINIBAR
RM0010001 	TV
RM0010002 	WIFI
RM0010003 	TV
RM0010004 	WIFI
RM0010004 	DESK
RM0010004 	COFFEE_MAKER
RM0010004 	AIR_CONDITION
RM0010004 	SAFE
RM0010004 	MINIBAR
RM0010005 	FRIDGE
RM0010005 	IRON
RM0010005 	DESK
RM0010006 	SAFE
RM0010007 	IRON
RM0010007 	TV
RM0010007 	HAIRDRYER
RM0010007 	MICROWAVE
RM0010007 	MINIBAR
RM0010007 	COFFEE_MAKER
RM0010007 	SAFE
RM0010008 	HAIRDRYER
RM0010008 	MICROWAVE
RM0010008 	DESK
RM0010008 	AIR_CONDITION
RM0010008 	TV
RM0010008 	FRIDGE
RM0010008 	MINIBAR
RM0010008 	WIFI
RM0010009 	MICROWAVE
RM0010009 	DESK
RM0010009 	SAFE
RM0010009 	COFFEE_MAKER
RM0010009 	HAIRDRYER
RM0010009 	TV
RM0010009 	MINIBAR
RM0010009 	FRIDGE
RM0010010 	TV
RM0010010 	WIFI
RM0010010 	IRON
RM0010010 	AIR_CONDITION
RM0010010 	FRIDGE
RM0010010 	MINIBAR
RM0010010 	MICROWAVE
RM0010010 	DESK
RM0010010 	SAFE
RM0010010 	HAIRDRYER
RM0010011 	COFFEE_MAKER
RM0010011 	FRIDGE
RM0010011 	MICROWAVE
RM0010011 	IRON
RM0010011 	DESK
RM0010012 	COFFEE_MAKER
RM0010012 	SAFE
RM0010012 	MINIBAR
RM0010012 	AIR_CONDITION
RM0010012 	WIFI
RM0010013 	HAIRDRYER
RM0010013 	FRIDGE
RM0010013 	COFFEE_MAKER
RM0010014 	SAFE
RM0010014 	MICROWAVE
RM0010015 	IRON
RM0010015 	FRIDGE
RM0010015 	SAFE
RM0010015 	AIR_CONDITION
RM0010015 	TV
RM0010015 	COFFEE_MAKER
RM0010015 	MICROWAVE
RM0010100 	HAIRDRYER
RM0010100 	MINIBAR
RM0010100 	DESK
RM0010100 	SAFE
RM0010100 	MICROWAVE
RM0010100 	FRIDGE
RM0010101 	MINIBAR
RM0010101 	MICROWAVE
RM0010101 	WIFI
RM0010101 	FRIDGE
RM0010101 	COFFEE_MAKER
RM0010101 	TV
RM0010101 	IRON
RM0010101 	DESK
RM0010101 	SAFE
RM0010101 	HAIRDRYER
RM0010102 	MINIBAR
RM0010102 	FRIDGE
RM0010103 	HAIRDRYER
RM0010103 	DESK
RM0010103 	IRON
RM0010103 	SAFE
RM0010103 	TV
RM0010103 	MINIBAR
RM0010103 	AIR_CONDITION
RM0010103 	COFFEE_MAKER
RM0010103 	FRIDGE
RM0010104 	AIR_CONDITION
RM0010104 	COFFEE_MAKER
RM0010104 	SAFE
RM0010104 	DESK
RM0010104 	WIFI
RM0010104 	MINIBAR
RM0010104 	FRIDGE
RM0010105 	TV
RM0010105 	COFFEE_MAKER
RM0010105 	MINIBAR
RM0010105 	FRIDGE
RM0010105 	MICROWAVE
RM0010105 	IRON
RM0010105 	WIFI
RM0010106 	COFFEE_MAKER
RM0010106 	WIFI
RM0010106 	HAIRDRYER
RM0010106 	MICROWAVE
RM0010107 	IRON
RM0010107 	TV
RM0010107 	DESK
RM0010107 	SAFE
RM0010107 	FRIDGE
RM0010107 	HAIRDRYER
RM0010107 	MICROWAVE
RM0010107 	WIFI
RM0010107 	AIR_CONDITION
RM0010107 	COFFEE_MAKER
RM0010108 	HAIRDRYER
RM0010108 	FRIDGE
RM0010108 	SAFE
RM0010108 	IRON
RM0010108 	TV
RM0010109 	WIFI
RM0010109 	AIR_CONDITION
RM0010109 	MICROWAVE
RM0010109 	TV
RM0010109 	DESK
RM0010109 	SAFE
RM0010109 	IRON
RM0010109 	MINIBAR
RM0010110 	MINIBAR
RM0010110 	WIFI
RM0010110 	TV
RM0010110 	MICROWAVE
RM0010110 	DESK
RM0010110 	COFFEE_MAKER
RM0010110 	FRIDGE
RM0010110 	AIR_CONDITION
RM0010110 	SAFE
RM0010110 	IRON
RM0010111 	MICROWAVE
RM0010111 	HAIRDRYER
RM0010111 	IRON
RM0010111 	SAFE
RM0010111 	AIR_CONDITION
RM0010111 	DESK
RM0010111 	WIFI
RM0010112 	IRON
RM0010112 	COFFEE_MAKER
RM0010113 	WIFI
RM0010114 	DESK
RM0010114 	MICROWAVE
RM0010114 	MINIBAR
RM0010200 	WIFI
RM0010200 	AIR_CONDITION
RM0010200 	TV
RM0010200 	DESK
RM0010200 	MICROWAVE
RM0010200 	MINIBAR
RM0010200 	IRON
RM0010200 	SAFE
RM0010200 	HAIRDRYER
RM0010200 	COFFEE_MAKER
RM0010200 	FRIDGE
RM0010201 	TV
RM0010201 	HAIRDRYER
RM0010201 	AIR_CONDITION
RM0010201 	FRIDGE
RM0010201 	SAFE
RM0010202 	TV
RM0010202 	FRIDGE
RM0010202 	MINIBAR
RM0010203 	DESK
RM0010203 	FRIDGE
RM0010203 	IRON
RM0010203 	TV
RM0010203 	COFFEE_MAKER
RM0010203 	SAFE
RM0010203 	WIFI
RM0010204 	TV
RM0010205 	AIR_CONDITION
RM0010205 	MINIBAR
RM0010205 	TV
RM0010206 	AIR_CONDITION
RM0010206 	TV
RM0010206 	MICROWAVE
RM0010206 	IRON
RM0010206 	MINIBAR
RM0010206 	FRIDGE
RM0010206 	DESK
RM0010207 	SAFE
RM0010207 	HAIRDRYER
RM0010207 	WIFI
RM0010207 	FRIDGE
RM0010208 	TV
RM0010208 	SAFE
RM0010208 	HAIRDRYER
RM0010208 	MICROWAVE
RM0010208 	WIFI
RM0010208 	MINIBAR
RM0010208 	AIR_CONDITION
RM0010208 	IRON
RM0010209 	AIR_CONDITION
RM0010209 	WIFI
RM0010209 	IRON
RM0010209 	MICROWAVE
RM0010209 	MINIBAR
RM0010210 	MINIBAR
RM0010210 	FRIDGE
RM0010210 	COFFEE_MAKER
RM0010210 	AIR_CONDITION
RM0010210 	SAFE
RM0010210 	WIFI
RM0010210 	IRON
RM0010210 	DESK
RM0010210 	HAIRDRYER
RM0010210 	MICROWAVE
RM0010210 	TV
RM0010211 	FRIDGE
RM0010211 	AIR_CONDITION
RM0010211 	HAIRDRYER
RM0010212 	TV
RM0010212 	WIFI
RM0010212 	AIR_CONDITION
RM0010212 	IRON
RM0010212 	FRIDGE
RM0010213 	WIFI
RM0010213 	AIR_CONDITION
RM0010213 	FRIDGE
RM0010213 	MINIBAR
RM0010213 	SAFE
RM0010213 	TV
RM0010213 	IRON
RM0010214 	AIR_CONDITION
RM0010300 	IRON
RM0010300 	COFFEE_MAKER
RM0010300 	HAIRDRYER
RM0010300 	FRIDGE
RM0010300 	AIR_CONDITION
RM0010301 	IRON
RM0010301 	FRIDGE
RM0010301 	COFFEE_MAKER
RM0010301 	TV
RM0010301 	HAIRDRYER
RM0010301 	MINIBAR
RM0010302 	AIR_CONDITION
RM0010302 	SAFE
RM0010302 	MINIBAR
RM0010302 	COFFEE_MAKER
RM0010302 	IRON
RM0010302 	FRIDGE
RM0010303 	DESK
RM0010304 	AIR_CONDITION
RM0010304 	DESK
RM0010304 	WIFI
RM0010304 	MICROWAVE
RM0010304 	IRON
RM0010305 	COFFEE_MAKER
RM0010305 	MINIBAR
RM0010306 	AIR_CONDITION
RM0010306 	HAIRDRYER
RM0010307 	DESK
RM0010307 	WIFI
RM0010307 	MINIBAR
RM0010307 	SAFE
RM0010307 	AIR_CONDITION
RM0010307 	HAIRDRYER
RM0010307 	COFFEE_MAKER
RM0010308 	SAFE
RM0010308 	AIR_CONDITION
RM0010308 	HAIRDRYER
RM0010308 	MINIBAR
RM0010309 	SAFE
RM0010309 	WIFI
RM0010309 	IRON
RM0010309 	FRIDGE
RM0010309 	MICROWAVE
RM0010309 	DESK
RM0010309 	HAIRDRYER
RM0010310 	SAFE
RM0010310 	TV
RM0010310 	HAIRDRYER
RM0010310 	MINIBAR
RM0010310 	DESK
RM0010310 	AIR_CONDITION
RM0010311 	HAIRDRYER
RM0010311 	MINIBAR
RM0010311 	SAFE
RM0010311 	TV
RM0010311 	MICROWAVE
RM0010312 	DESK
RM0010312 	SAFE
RM0010312 	MICROWAVE
RM0010312 	HAIRDRYER
RM0010312 	AIR_CONDITION
RM0010312 	FRIDGE
RM0010312 	COFFEE_MAKER
RM0010312 	MINIBAR
RM0010313 	MICROWAVE
RM0010313 	COFFEE_MAKER
RM0010313 	FRIDGE
RM0010313 	MINIBAR
RM0010313 	IRON
RM0010313 	HAIRDRYER
RM0010313 	SAFE
RM0010313 	AIR_CONDITION
RM0010400 	WIFI
RM0010400 	COFFEE_MAKER
RM0010400 	FRIDGE
RM0010400 	TV
RM0010400 	MINIBAR
RM0010400 	HAIRDRYER
RM0010400 	AIR_CONDITION
RM0010401 	MINIBAR
RM0010401 	TV
RM0010401 	FRIDGE
RM0010401 	WIFI
RM0010401 	MICROWAVE
RM0010401 	IRON
RM0010402 	MINIBAR
RM0010402 	WIFI
RM0010402 	IRON
RM0010402 	TV
RM0010403 	AIR_CONDITION
RM0010403 	DESK
RM0010403 	MINIBAR
RM0010403 	WIFI
RM0010403 	IRON
RM0010403 	MICROWAVE
RM0010403 	SAFE
RM0010403 	FRIDGE
RM0010403 	TV
RM0010404 	HAIRDRYER
RM0010404 	MINIBAR
RM0010404 	COFFEE_MAKER
RM0010404 	TV
RM0010404 	SAFE
RM0010404 	WIFI
RM0010404 	MICROWAVE
RM0010404 	AIR_CONDITION
RM0010404 	DESK
RM0010404 	IRON
RM0010404 	FRIDGE
RM0010405 	HAIRDRYER
RM0010405 	COFFEE_MAKER
RM0010405 	MINIBAR
RM0010405 	DESK
RM0010405 	AIR_CONDITION
RM0010405 	WIFI
RM0010405 	FRIDGE
RM0010405 	TV
RM0010405 	SAFE
RM0010405 	MICROWAVE
RM0010406 	DESK
RM0010406 	TV
RM0010406 	MINIBAR
RM0010406 	FRIDGE
RM0010406 	SAFE
RM0010406 	WIFI
RM0010406 	HAIRDRYER
RM0010406 	IRON
RM0010406 	AIR_CONDITION
RM0010407 	COFFEE_MAKER
RM0010407 	FRIDGE
RM0010407 	IRON
RM0010407 	AIR_CONDITION
RM0010407 	HAIRDRYER
RM0010407 	SAFE
RM0010408 	HAIRDRYER
RM0010408 	COFFEE_MAKER
RM0010408 	FRIDGE
RM0010409 	DESK
RM0010409 	MINIBAR
RM0010409 	WIFI
RM0010410 	MICROWAVE
RM0010410 	MINIBAR
RM0010410 	WIFI
RM0010410 	IRON
RM0010410 	TV
RM0010410 	AIR_CONDITION
RM0010410 	DESK
RM0010410 	COFFEE_MAKER
RM0010410 	HAIRDRYER
RM0010410 	SAFE
RM0010410 	FRIDGE
RM0010411 	SAFE
RM0010411 	FRIDGE
RM0010411 	IRON
RM0010411 	HAIRDRYER
RM0010411 	AIR_CONDITION
RM0010411 	MINIBAR
RM0010411 	MICROWAVE
RM0010411 	WIFI
RM0010411 	COFFEE_MAKER
RM0010412 	MICROWAVE
RM0010412 	FRIDGE
RM0010412 	HAIRDRYER
RM0010412 	AIR_CONDITION
RM0010412 	TV
RM0010412 	MINIBAR
RM0010413 	HAIRDRYER
RM0010413 	MICROWAVE
RM0010413 	MINIBAR
RM0010414 	MINIBAR
RM0010414 	MICROWAVE
RM0010414 	TV
RM0010414 	HAIRDRYER
RM0010414 	SAFE
RM0010414 	WIFI
RM0010415 	DESK
RM0010415 	MICROWAVE
RM0010415 	HAIRDRYER
RM0010415 	IRON
RM0010415 	COFFEE_MAKER
RM0010415 	MINIBAR
RM0010415 	TV
RM0010415 	AIR_CONDITION
RM0010500 	FRIDGE
RM0010500 	IRON
RM0010501 	FRIDGE
RM0010501 	MINIBAR
RM0010501 	WIFI
RM0010501 	COFFEE_MAKER
RM0010501 	AIR_CONDITION
RM0010501 	HAIRDRYER
RM0010501 	MICROWAVE
RM0010501 	IRON
RM0010502 	AIR_CONDITION
RM0010502 	FRIDGE
RM0010502 	HAIRDRYER
RM0010502 	IRON
RM0010503 	SAFE
RM0010503 	MINIBAR
RM0010503 	COFFEE_MAKER
RM0010503 	IRON
RM0010504 	MICROWAVE
RM0010504 	SAFE
RM0010504 	DESK
RM0010504 	COFFEE_MAKER
RM0010504 	MINIBAR
RM0010504 	AIR_CONDITION
RM0010504 	HAIRDRYER
RM0010505 	DESK
RM0010505 	COFFEE_MAKER
RM0010505 	AIR_CONDITION
RM0010505 	MINIBAR
RM0010505 	FRIDGE
RM0010505 	WIFI
RM0010506 	MINIBAR
RM0010506 	COFFEE_MAKER
RM0010506 	FRIDGE
RM0010506 	IRON
RM0010507 	WIFI
RM0010507 	IRON
RM0010507 	HAIRDRYER
RM0010507 	FRIDGE
RM0010507 	COFFEE_MAKER
RM0010508 	MICROWAVE
RM0010508 	AIR_CONDITION
RM0010508 	WIFI
RM0010508 	FRIDGE
RM0010508 	SAFE
RM0010508 	COFFEE_MAKER
RM0010509 	MINIBAR
RM0010509 	IRON
RM0010509 	TV
RM0010509 	WIFI
RM0010510 	TV
RM0010510 	SAFE
RM0010510 	AIR_CONDITION
RM0010510 	HAIRDRYER
RM0010510 	IRON
RM0010510 	MICROWAVE
RM0010511 	AIR_CONDITION
RM0010511 	DESK
RM0010511 	HAIRDRYER
RM0010511 	TV
RM0010512 	IRON
RM0010512 	AIR_CONDITION
RM0010512 	DESK
RM0010512 	WIFI
RM0010512 	COFFEE_MAKER
RM0010512 	FRIDGE
RM0010512 	HAIRDRYER
RM0010513 	WIFI
RM0010513 	AIR_CONDITION
RM0010513 	DESK
RM0010513 	SAFE
RM0010513 	COFFEE_MAKER
RM0010513 	FRIDGE
RM0010513 	MINIBAR
RM0010513 	HAIRDRYER
RM0010514 	MINIBAR
RM0010514 	AIR_CONDITION
RM0010514 	WIFI
RM0010514 	DESK
RM0010514 	MICROWAVE
RM0010514 	COFFEE_MAKER
RM0010514 	FRIDGE
RM0010514 	IRON
RM0010514 	TV
RM0010514 	HAIRDRYER
RM0010515 	MICROWAVE
RM0010515 	COFFEE_MAKER
RM0010515 	AIR_CONDITION
RM0010515 	TV
RM0010515 	WIFI
RM0010515 	HAIRDRYER
RM0010516 	MICROWAVE
RM0010516 	TV
RM0010516 	DESK
RM0010516 	FRIDGE
RM0010516 	HAIRDRYER
RM0010516 	AIR_CONDITION
RM0010516 	WIFI
RM0010517 	COFFEE_MAKER
RM0010600 	TV
RM0010600 	DESK
RM0010600 	IRON
RM0010600 	FRIDGE
RM0010600 	WIFI
RM0010601 	MINIBAR
RM0010602 	FRIDGE
RM0010602 	SAFE
RM0010602 	MINIBAR
RM0010602 	HAIRDRYER
RM0010602 	WIFI
RM0010602 	TV
RM0010602 	AIR_CONDITION
RM0010602 	DESK
RM0010602 	MICROWAVE
RM0010603 	HAIRDRYER
RM0010603 	WIFI
RM0010603 	MINIBAR
RM0010603 	COFFEE_MAKER
RM0010603 	IRON
RM0010603 	AIR_CONDITION
RM0010603 	TV
RM0010603 	DESK
RM0010603 	MICROWAVE
RM0010604 	MICROWAVE
RM0010604 	TV
RM0010604 	DESK
RM0010604 	HAIRDRYER
RM0010604 	MINIBAR
RM0010604 	SAFE
RM0010605 	IRON
RM0010605 	COFFEE_MAKER
RM0010605 	AIR_CONDITION
RM0010605 	WIFI
RM0010606 	DESK
RM0010606 	IRON
RM0010606 	COFFEE_MAKER
RM0010607 	COFFEE_MAKER
RM0010607 	MINIBAR
RM0010607 	IRON
RM0010607 	FRIDGE
RM0010607 	AIR_CONDITION
RM0010607 	WIFI
RM0010607 	DESK
RM0010607 	SAFE
RM0010607 	TV
RM0010607 	HAIRDRYER
RM0010607 	MICROWAVE
RM0010608 	IRON
RM0010608 	HAIRDRYER
RM0010608 	SAFE
RM0010609 	FRIDGE
RM0010609 	TV
RM0010609 	SAFE
RM0010609 	IRON
RM0010609 	WIFI
RM0010609 	MICROWAVE
RM0010609 	MINIBAR
RM0010610 	WIFI
RM0010610 	MINIBAR
RM0010610 	TV
RM0010610 	HAIRDRYER
RM0010610 	SAFE
RM0010610 	MICROWAVE
RM0010610 	IRON
RM0010610 	DESK
RM0010610 	FRIDGE
RM0010610 	COFFEE_MAKER
RM0010700 	DESK
RM0010700 	IRON
RM0010700 	MINIBAR
RM0010701 	FRIDGE
RM0010701 	AIR_CONDITION
RM0010701 	TV
RM0010701 	MINIBAR
RM0010701 	MICROWAVE
RM0010701 	IRON
RM0010701 	DESK
RM0010701 	COFFEE_MAKER
RM0010701 	WIFI
RM0010702 	SAFE
RM0010702 	AIR_CONDITION
RM0010702 	WIFI
RM0010702 	MINIBAR
RM0010702 	MICROWAVE
RM0010702 	DESK
RM0010702 	FRIDGE
RM0010702 	COFFEE_MAKER
RM0010702 	HAIRDRYER
RM0010702 	TV
RM0010702 	IRON
RM0010703 	DESK
RM0010703 	IRON
RM0010703 	SAFE
RM0010704 	WIFI
RM0010704 	IRON
RM0010704 	COFFEE_MAKER
RM0010704 	TV
RM0010704 	MINIBAR
RM0010704 	DESK
RM0010704 	AIR_CONDITION
RM0010704 	FRIDGE
RM0010704 	HAIRDRYER
RM0010704 	MICROWAVE
RM0010705 	HAIRDRYER
RM0010705 	MINIBAR
RM0010705 	DESK
RM0010705 	WIFI
RM0010705 	TV
RM0010706 	HAIRDRYER
RM0010706 	AIR_CONDITION
RM0010706 	MINIBAR
RM0010706 	IRON
RM0010706 	DESK
RM0010707 	IRON
RM0010707 	DESK
RM0010707 	MINIBAR
RM0010707 	TV
RM0010708 	HAIRDRYER
RM0010708 	DESK
RM0010708 	MINIBAR
RM0010708 	MICROWAVE
RM0010708 	AIR_CONDITION
RM0010708 	IRON
RM0010708 	TV
RM0010708 	FRIDGE
RM0010708 	SAFE
RM0010708 	WIFI
RM0010709 	DESK
RM0010709 	MICROWAVE
RM0010710 	MICROWAVE
RM0010710 	WIFI
RM0010710 	HAIRDRYER
RM0010711 	FRIDGE
RM0010711 	AIR_CONDITION
RM0010711 	DESK
RM0010711 	HAIRDRYER
RM0010711 	TV
RM0010711 	MICROWAVE
RM0010711 	IRON
RM0010712 	FRIDGE
RM0010712 	SAFE
RM0010712 	HAIRDRYER
RM0010713 	MINIBAR
RM0010713 	IRON
RM0010714 	TV
RM0010714 	DESK
RM0010714 	AIR_CONDITION
RM0010714 	FRIDGE
RM0010714 	SAFE
RM0010714 	COFFEE_MAKER
RM0010715 	COFFEE_MAKER
RM0010715 	IRON
RM0010715 	MICROWAVE
RM0010715 	AIR_CONDITION
RM0010715 	FRIDGE
RM0010715 	DESK
RM0010715 	MINIBAR
RM0010715 	WIFI
RM0010715 	TV
RM0010800 	AIR_CONDITION
RM0010800 	MICROWAVE
RM0010800 	WIFI
RM0010800 	DESK
RM0010800 	MINIBAR
RM0010800 	IRON
RM0010800 	TV
RM0010800 	SAFE
RM0010800 	HAIRDRYER
RM0010800 	COFFEE_MAKER
RM0010800 	FRIDGE
RM0010801 	COFFEE_MAKER
RM0010801 	HAIRDRYER
RM0010801 	AIR_CONDITION
RM0010801 	SAFE
RM0010802 	TV
RM0010802 	WIFI
RM0010802 	HAIRDRYER
RM0010802 	SAFE
RM0010802 	MINIBAR
RM0010802 	DESK
RM0010802 	FRIDGE
RM0010802 	IRON
RM0010802 	AIR_CONDITION
RM0010802 	MICROWAVE
RM0010802 	COFFEE_MAKER
RM0010803 	SAFE
RM0010803 	MINIBAR
RM0010803 	AIR_CONDITION
RM0010803 	HAIRDRYER
RM0010803 	DESK
RM0010803 	IRON
RM0010803 	COFFEE_MAKER
RM0010804 	MICROWAVE
RM0010804 	AIR_CONDITION
RM0010804 	SAFE
RM0010804 	MINIBAR
RM0010804 	TV
RM0010804 	FRIDGE
RM0010805 	IRON
RM0010805 	WIFI
RM0010806 	FRIDGE
RM0010806 	SAFE
RM0010806 	HAIRDRYER
RM0010806 	DESK
RM0010806 	TV
RM0010806 	IRON
RM0010806 	COFFEE_MAKER
RM0010806 	WIFI
RM0010807 	HAIRDRYER
RM0010807 	WIFI
RM0010807 	MINIBAR
RM0010807 	IRON
RM0010807 	AIR_CONDITION
RM0010807 	TV
RM0010807 	COFFEE_MAKER
RM0010808 	TV
RM0010809 	FRIDGE
RM0010809 	MICROWAVE
RM0010809 	SAFE
RM0010809 	MINIBAR
RM0010809 	HAIRDRYER
RM0010809 	IRON
RM0010809 	TV
RM0010809 	AIR_CONDITION
RM0010809 	COFFEE_MAKER
RM0010809 	WIFI
RM0010809 	DESK
RM0010810 	MINIBAR
RM0010810 	MICROWAVE
RM0010810 	IRON
RM0010810 	WIFI
RM0010810 	HAIRDRYER
RM0010810 	SAFE
RM0010810 	COFFEE_MAKER
RM0010810 	FRIDGE
RM0010811 	FRIDGE
RM0010811 	MINIBAR
RM0010811 	WIFI
RM0010812 	FRIDGE
RM0010812 	MICROWAVE
RM0010812 	DESK
RM0010812 	MINIBAR
RM0010812 	AIR_CONDITION
RM0010812 	COFFEE_MAKER
RM0010812 	WIFI
RM0010812 	SAFE
RM0010812 	IRON
RM0010813 	TV
RM0010814 	HAIRDRYER
RM0010814 	COFFEE_MAKER
RM0010815 	FRIDGE
RM0010815 	HAIRDRYER
RM0010815 	MINIBAR
RM0010815 	DESK
RM0010815 	WIFI
RM0010815 	TV
RM0010815 	SAFE
RM0010815 	IRON
RM0010815 	COFFEE_MAKER
RM0010900 	DESK
RM0010900 	COFFEE_MAKER
RM0010900 	IRON
RM0010900 	TV
RM0010900 	HAIRDRYER
RM0010900 	MINIBAR
RM0010900 	AIR_CONDITION
RM0010900 	FRIDGE
RM0010900 	SAFE
RM0010900 	MICROWAVE
RM0010901 	MICROWAVE
RM0010901 	HAIRDRYER
RM0010901 	DESK
RM0010901 	AIR_CONDITION
RM0010901 	MINIBAR
RM0010901 	FRIDGE
RM0010901 	COFFEE_MAKER
RM0010901 	WIFI
RM0010901 	IRON
RM0010902 	FRIDGE
RM0010903 	MICROWAVE
RM0010903 	IRON
RM0010903 	HAIRDRYER
RM0010903 	TV
RM0010903 	COFFEE_MAKER
RM0010903 	DESK
RM0010903 	WIFI
RM0010903 	SAFE
RM0010904 	AIR_CONDITION
RM0010904 	TV
RM0010904 	SAFE
RM0010904 	COFFEE_MAKER
RM0010904 	FRIDGE
RM0010904 	DESK
RM0010904 	MINIBAR
RM0010904 	HAIRDRYER
RM0010904 	WIFI
RM0010904 	IRON
RM0010905 	TV
RM0010905 	COFFEE_MAKER
RM0010905 	MICROWAVE
RM0010905 	SAFE
RM0010905 	IRON
RM0010906 	DESK
RM0010906 	MINIBAR
RM0010906 	COFFEE_MAKER
RM0010906 	HAIRDRYER
RM0010906 	SAFE
RM0010906 	AIR_CONDITION
RM0010906 	WIFI
RM0010907 	COFFEE_MAKER
RM0010907 	WIFI
RM0010907 	IRON
RM0010907 	DESK
RM0010907 	FRIDGE
RM0010907 	SAFE
RM0010907 	AIR_CONDITION
RM0010907 	HAIRDRYER
RM0010907 	MICROWAVE
RM0010908 	HAIRDRYER
RM0010908 	MINIBAR
RM0010908 	DESK
RM0010908 	WIFI
RM0010908 	TV
RM0010908 	COFFEE_MAKER
RM0010908 	SAFE
RM0010909 	MICROWAVE
RM0010909 	COFFEE_MAKER
RM0010909 	MINIBAR
RM0010909 	SAFE
RM0010909 	AIR_CONDITION
RM0010909 	DESK
RM0010909 	TV
RM0010909 	FRIDGE
RM0010909 	HAIRDRYER
RM0010909 	WIFI
RM0010909 	IRON
RM0010910 	IRON
RM0010910 	SAFE
RM0010910 	TV
RM0010910 	COFFEE_MAKER
RM0010910 	WIFI
RM0010910 	AIR_CONDITION
RM0010910 	HAIRDRYER
RM0010910 	MICROWAVE
RM0010910 	MINIBAR
RM0010910 	DESK
RM0010911 	TV
RM0010911 	MICROWAVE
RM0010911 	IRON
RM0010911 	WIFI
RM0010911 	MINIBAR
RM0010911 	SAFE
RM0010911 	HAIRDRYER
RM0010911 	DESK
RM0010911 	AIR_CONDITION
RM0011000 	WIFI
RM0011001 	FRIDGE
RM0011002 	TV
RM0011003 	MICROWAVE
RM0011003 	DESK
RM0011003 	HAIRDRYER
RM0011003 	FRIDGE
RM0011003 	AIR_CONDITION
RM0011003 	IRON
RM0011004 	AIR_CONDITION
RM0011004 	FRIDGE
RM0011004 	HAIRDRYER
RM0011004 	WIFI
RM0011004 	DESK
RM0011004 	IRON
RM0011005 	SAFE
RM0011005 	TV
RM0011005 	MICROWAVE
RM0011005 	FRIDGE
RM0011005 	WIFI
RM0011005 	AIR_CONDITION
RM0011006 	MINIBAR
RM0011006 	IRON
RM0011006 	DESK
RM0011006 	HAIRDRYER
RM0011006 	TV
RM0011006 	COFFEE_MAKER
RM0011006 	SAFE
RM0011006 	WIFI
RM0011007 	COFFEE_MAKER
RM0011007 	HAIRDRYER
RM0011007 	MICROWAVE
RM0011007 	SAFE
RM0011008 	IRON
RM0011009 	WIFI
RM0011009 	DESK
RM0011009 	MICROWAVE
RM0011009 	HAIRDRYER
RM0011009 	AIR_CONDITION
RM0011009 	IRON
RM0011009 	SAFE
RM0011009 	MINIBAR
RM0011009 	FRIDGE
RM0011010 	SAFE
RM0011010 	WIFI
RM0011011 	HAIRDRYER
RM0011011 	IRON
RM0011011 	AIR_CONDITION
RM0011011 	SAFE
RM0011011 	MINIBAR
RM0011011 	WIFI
RM0011011 	COFFEE_MAKER
RM0011011 	TV
RM0011011 	FRIDGE
RM0011011 	MICROWAVE
RM0011012 	FRIDGE
RM0011012 	IRON
RM0011012 	SAFE
RM0011013 	HAIRDRYER
RM0011013 	AIR_CONDITION
RM0011013 	TV
RM0011014 	COFFEE_MAKER
RM0011014 	DESK
RM0011014 	HAIRDRYER
RM0011014 	TV
RM0011014 	WIFI
RM0011014 	MICROWAVE
RM0011014 	MINIBAR
RM0011014 	FRIDGE
RM0011014 	IRON
RM0011015 	AIR_CONDITION
RM0011015 	HAIRDRYER
RM0011015 	TV
RM0011015 	IRON
RM0011015 	DESK
RM0011015 	WIFI
RM0011015 	SAFE
RM0011015 	COFFEE_MAKER
RM0011015 	MICROWAVE
RM0011016 	MINIBAR
RM0011016 	SAFE
RM0011016 	HAIRDRYER
RM0011016 	COFFEE_MAKER
RM0011016 	TV
RM0011016 	MICROWAVE
RM0011016 	AIR_CONDITION
RM0011016 	FRIDGE
RM0011016 	DESK
RM0011017 	COFFEE_MAKER
RM0011017 	MINIBAR
RM0011017 	IRON
RM0011100 	IRON
RM0011100 	MINIBAR
RM0011100 	FRIDGE
RM0011100 	MICROWAVE
RM0011100 	SAFE
RM0011100 	COFFEE_MAKER
RM0011101 	FRIDGE
RM0011101 	DESK
RM0011101 	HAIRDRYER
RM0011101 	TV
RM0011101 	SAFE
RM0011102 	AIR_CONDITION
RM0011102 	WIFI
RM0011102 	MICROWAVE
RM0011102 	MINIBAR
RM0011102 	SAFE
RM0011102 	TV
RM0011102 	HAIRDRYER
RM0011103 	COFFEE_MAKER
RM0011103 	HAIRDRYER
RM0011103 	MINIBAR
RM0011103 	TV
RM0011103 	DESK
RM0011103 	IRON
RM0011103 	AIR_CONDITION
RM0011103 	SAFE
RM0011104 	DESK
RM0011104 	AIR_CONDITION
RM0011105 	COFFEE_MAKER
RM0011105 	DESK
RM0011105 	MICROWAVE
RM0011105 	WIFI
RM0011106 	IRON
RM0011106 	FRIDGE
RM0011106 	DESK
RM0011106 	SAFE
RM0011106 	MINIBAR
RM0011107 	FRIDGE
RM0011107 	COFFEE_MAKER
RM0011107 	MINIBAR
RM0011107 	WIFI
RM0011107 	SAFE
RM0011107 	HAIRDRYER
RM0011107 	AIR_CONDITION
RM0011107 	IRON
RM0011108 	FRIDGE
RM0011108 	IRON
RM0011108 	AIR_CONDITION
RM0011108 	COFFEE_MAKER
RM0011108 	TV
RM0011108 	HAIRDRYER
RM0011108 	MICROWAVE
RM0011108 	DESK
RM0011109 	MINIBAR
RM0011109 	WIFI
RM0011109 	IRON
RM0011109 	AIR_CONDITION
RM0011109 	COFFEE_MAKER
RM0011109 	HAIRDRYER
RM0011109 	FRIDGE
RM0011109 	TV
RM0011109 	SAFE
RM0011109 	MICROWAVE
RM0011110 	WIFI
RM0011110 	TV
RM0011110 	HAIRDRYER
RM0011111 	AIR_CONDITION
RM0011111 	HAIRDRYER
RM0011111 	DESK
RM0011111 	WIFI
RM0011111 	IRON
RM0011111 	MINIBAR
RM0011112 	IRON
RM0011112 	AIR_CONDITION
RM0011112 	COFFEE_MAKER
RM0011112 	HAIRDRYER
RM0011112 	WIFI
RM0011112 	TV
RM0011112 	MINIBAR
RM0011112 	SAFE
RM0011112 	MICROWAVE
RM0011113 	AIR_CONDITION
RM0011113 	HAIRDRYER
RM0011113 	MICROWAVE
RM0011113 	MINIBAR
RM0011113 	TV
RM0011113 	IRON
RM0011113 	SAFE
RM0011113 	COFFEE_MAKER
RM0011113 	FRIDGE
RM0011114 	MICROWAVE
RM0011114 	SAFE
RM0011114 	WIFI
RM0011115 	MICROWAVE
RM0011115 	TV
RM0011115 	COFFEE_MAKER
RM0011115 	HAIRDRYER
RM0011115 	DESK
RM0011115 	AIR_CONDITION
RM0011115 	WIFI
RM0011115 	FRIDGE
RM0011115 	IRON
RM0011200 	MICROWAVE
RM0011200 	SAFE
RM0011200 	WIFI
RM0011200 	DESK
RM0011201 	TV
RM0011201 	IRON
RM0011201 	DESK
RM0011201 	HAIRDRYER
RM0011201 	MINIBAR
RM0011201 	COFFEE_MAKER
RM0011201 	FRIDGE
RM0011202 	COFFEE_MAKER
RM0011202 	WIFI
RM0011202 	FRIDGE
RM0011202 	MICROWAVE
RM0011202 	DESK
RM0011202 	MINIBAR
RM0011202 	TV
RM0011202 	AIR_CONDITION
RM0011202 	IRON
RM0011202 	HAIRDRYER
RM0011202 	SAFE
RM0011203 	SAFE
RM0011203 	COFFEE_MAKER
RM0011203 	IRON
RM0011203 	HAIRDRYER
RM0011203 	TV
RM0011204 	TV
RM0011204 	HAIRDRYER
RM0011204 	AIR_CONDITION
RM0011204 	COFFEE_MAKER
RM0011204 	SAFE
RM0011204 	FRIDGE
RM0011204 	WIFI
RM0011205 	AIR_CONDITION
RM0011205 	MINIBAR
RM0011205 	HAIRDRYER
RM0011205 	WIFI
RM0011205 	MICROWAVE
RM0011205 	FRIDGE
RM0011205 	IRON
RM0011206 	HAIRDRYER
RM0011206 	DESK
RM0011207 	WIFI
RM0011207 	FRIDGE
RM0011207 	AIR_CONDITION
RM0011207 	DESK
RM0011207 	IRON
RM0011208 	IRON
RM0011208 	SAFE
RM0011208 	AIR_CONDITION
RM0011208 	MICROWAVE
RM0011208 	DESK
RM0011208 	COFFEE_MAKER
RM0011208 	WIFI
RM0011209 	DESK
RM0011209 	WIFI
RM0011209 	HAIRDRYER
RM0011210 	COFFEE_MAKER
RM0011210 	IRON
RM0011210 	HAIRDRYER
RM0011210 	WIFI
RM0011210 	FRIDGE
RM0011210 	MINIBAR
RM0011210 	MICROWAVE
RM0011210 	DESK
RM0011211 	MICROWAVE
RM0011211 	COFFEE_MAKER
RM0011211 	WIFI
RM0011211 	FRIDGE
RM0011211 	TV
RM0011211 	HAIRDRYER
RM0011211 	DESK
RM0011211 	AIR_CONDITION
RM0011211 	MINIBAR
RM0011211 	SAFE
RM0011212 	IRON
RM0011213 	AIR_CONDITION
RM0011213 	FRIDGE
RM0011213 	COFFEE_MAKER
RM0011213 	DESK
RM0011213 	MICROWAVE
RM0011213 	SAFE
RM0011213 	HAIRDRYER
RM0011213 	WIFI
RM0011214 	AIR_CONDITION
RM0011214 	COFFEE_MAKER
RM0011215 	DESK
RM0011215 	SAFE
RM0011215 	TV
RM0011215 	FRIDGE
RM0011215 	WIFI
RM0011215 	COFFEE_MAKER
RM0011215 	MINIBAR
RM0011215 	MICROWAVE
RM0011215 	AIR_CONDITION
RM0011216 	SAFE
RM0011216 	COFFEE_MAKER
RM0011216 	MINIBAR
RM0011216 	WIFI
RM0011216 	AIR_CONDITION
RM0011216 	DESK
RM0011217 	HAIRDRYER
RM0011300 	MINIBAR
RM0011300 	MICROWAVE
RM0011300 	TV
RM0011301 	HAIRDRYER
RM0011301 	SAFE
RM0011301 	FRIDGE
RM0011302 	WIFI
RM0011302 	DESK
RM0011302 	AIR_CONDITION
RM0011302 	TV
RM0011302 	FRIDGE
RM0011302 	MINIBAR
RM0011302 	MICROWAVE
RM0011302 	IRON
RM0011303 	AIR_CONDITION
RM0011303 	COFFEE_MAKER
RM0011303 	SAFE
RM0011303 	FRIDGE
RM0011303 	HAIRDRYER
RM0011303 	MINIBAR
RM0011303 	IRON
RM0011303 	WIFI
RM0011303 	DESK
RM0011303 	MICROWAVE
RM0011303 	TV
RM0011304 	AIR_CONDITION
RM0011304 	MINIBAR
RM0011304 	COFFEE_MAKER
RM0011304 	WIFI
RM0011304 	HAIRDRYER
RM0011304 	SAFE
RM0011304 	FRIDGE
RM0011304 	MICROWAVE
RM0011304 	TV
RM0011304 	IRON
RM0011305 	TV
RM0011306 	DESK
RM0011306 	COFFEE_MAKER
RM0011306 	FRIDGE
RM0011306 	MINIBAR
RM0011307 	COFFEE_MAKER
RM0011307 	DESK
RM0011307 	AIR_CONDITION
RM0011307 	MINIBAR
RM0011308 	SAFE
RM0011308 	MICROWAVE
RM0011308 	MINIBAR
RM0011308 	COFFEE_MAKER
RM0011308 	FRIDGE
RM0011308 	TV
RM0011308 	AIR_CONDITION
RM0011308 	HAIRDRYER
RM0011308 	DESK
RM0011308 	IRON
RM0011309 	WIFI
RM0011309 	TV
RM0011309 	SAFE
RM0011309 	HAIRDRYER
RM0011309 	COFFEE_MAKER
RM0011309 	IRON
RM0011310 	TV
RM0011310 	SAFE
RM0011310 	WIFI
RM0011310 	MINIBAR
RM0011310 	MICROWAVE
RM0011310 	AIR_CONDITION
RM0011311 	WIFI
RM0011312 	COFFEE_MAKER
RM0011312 	SAFE
RM0011312 	TV
RM0011312 	AIR_CONDITION
RM0011313 	TV
RM0011314 	MICROWAVE
RM0011314 	AIR_CONDITION
RM0011314 	WIFI
RM0011314 	IRON
RM0011314 	TV
RM0011314 	SAFE
RM0011314 	HAIRDRYER
RM0011315 	SAFE
RM0011315 	MINIBAR
RM0011315 	DESK
RM0011400 	HAIRDRYER
RM0011400 	DESK
RM0011400 	TV
RM0011401 	SAFE
RM0011401 	TV
RM0011401 	COFFEE_MAKER
RM0011401 	IRON
RM0011401 	MINIBAR
RM0011401 	MICROWAVE
RM0011401 	FRIDGE
RM0011401 	AIR_CONDITION
RM0011402 	MINIBAR
RM0011402 	MICROWAVE
RM0011402 	AIR_CONDITION
RM0011402 	IRON
RM0011403 	WIFI
RM0011403 	HAIRDRYER
RM0011403 	AIR_CONDITION
RM0011403 	MICROWAVE
RM0011403 	IRON
RM0011403 	SAFE
RM0011404 	AIR_CONDITION
RM0011404 	MINIBAR
RM0011404 	FRIDGE
RM0011404 	HAIRDRYER
RM0011404 	IRON
RM0011404 	SAFE
RM0011404 	DESK
RM0011404 	WIFI
RM0011404 	TV
RM0011404 	COFFEE_MAKER
RM0011404 	MICROWAVE
RM0011405 	FRIDGE
RM0011406 	TV
RM0011406 	FRIDGE
RM0011406 	SAFE
RM0011406 	MICROWAVE
RM0011406 	DESK
RM0011406 	HAIRDRYER
RM0011406 	AIR_CONDITION
RM0011407 	WIFI
RM0011407 	SAFE
RM0011407 	AIR_CONDITION
RM0011407 	HAIRDRYER
RM0011407 	IRON
RM0011408 	DESK
RM0011408 	TV
RM0011408 	FRIDGE
RM0011408 	HAIRDRYER
RM0011408 	AIR_CONDITION
RM0011408 	WIFI
RM0011408 	MICROWAVE
RM0011408 	IRON
RM0011408 	SAFE
RM0011408 	COFFEE_MAKER
RM0011409 	DESK
RM0011409 	IRON
RM0011409 	AIR_CONDITION
RM0011409 	TV
RM0011409 	HAIRDRYER
RM0011409 	COFFEE_MAKER
RM0011410 	WIFI
RM0011410 	DESK
RM0011410 	MINIBAR
RM0011410 	SAFE
RM0011410 	HAIRDRYER
RM0011410 	TV
RM0011410 	COFFEE_MAKER
RM0011410 	AIR_CONDITION
RM0011410 	FRIDGE
RM0011410 	MICROWAVE
RM0011410 	IRON
RM0011411 	COFFEE_MAKER
RM0011411 	TV
RM0011411 	IRON
RM0011411 	FRIDGE
RM0011411 	WIFI
RM0011411 	MICROWAVE
RM0011411 	AIR_CONDITION
RM0011411 	HAIRDRYER
RM0011411 	DESK
RM0011412 	COFFEE_MAKER
RM0011412 	TV
RM0011412 	AIR_CONDITION
RM0011412 	SAFE
RM0011500 	SAFE
RM0011500 	HAIRDRYER
RM0011500 	DESK
RM0011500 	TV
RM0011500 	FRIDGE
RM0011501 	SAFE
RM0011501 	HAIRDRYER
RM0011501 	FRIDGE
RM0011501 	COFFEE_MAKER
RM0011501 	MINIBAR
RM0011501 	MICROWAVE
RM0011501 	AIR_CONDITION
RM0011502 	MICROWAVE
RM0011502 	FRIDGE
RM0011502 	WIFI
RM0011502 	IRON
RM0011502 	MINIBAR
RM0011502 	HAIRDRYER
RM0011502 	DESK
RM0011502 	TV
RM0011502 	COFFEE_MAKER
RM0011502 	AIR_CONDITION
RM0011503 	TV
RM0011503 	COFFEE_MAKER
RM0011503 	AIR_CONDITION
RM0011503 	IRON
RM0011503 	MINIBAR
RM0011503 	SAFE
RM0011504 	HAIRDRYER
RM0011504 	WIFI
RM0011504 	MICROWAVE
RM0011504 	TV
RM0011505 	HAIRDRYER
RM0011505 	FRIDGE
RM0011505 	MINIBAR
RM0011505 	COFFEE_MAKER
RM0011505 	AIR_CONDITION
RM0011505 	WIFI
RM0011505 	SAFE
RM0011505 	MICROWAVE
RM0011505 	DESK
RM0011506 	AIR_CONDITION
RM0011506 	FRIDGE
RM0011507 	FRIDGE
RM0011507 	IRON
RM0011507 	SAFE
RM0011507 	COFFEE_MAKER
RM0011507 	WIFI
RM0011507 	DESK
RM0011507 	HAIRDRYER
RM0011507 	MINIBAR
RM0011507 	TV
RM0011507 	MICROWAVE
RM0011508 	HAIRDRYER
RM0011508 	SAFE
RM0011508 	FRIDGE
RM0011508 	MICROWAVE
RM0011508 	DESK
RM0011508 	TV
RM0011508 	AIR_CONDITION
RM0011508 	IRON
RM0011508 	WIFI
RM0011508 	COFFEE_MAKER
RM0011508 	MINIBAR
RM0011509 	DESK
RM0011509 	AIR_CONDITION
RM0011509 	FRIDGE
RM0011509 	HAIRDRYER
RM0011509 	MINIBAR
RM0011509 	SAFE
RM0011509 	TV
RM0011510 	SAFE
RM0011510 	WIFI
RM0011510 	MINIBAR
RM0011510 	IRON
RM0011510 	DESK
RM0011510 	COFFEE_MAKER
RM0011510 	FRIDGE
RM0011511 	SAFE
RM0011511 	IRON
RM0011512 	MINIBAR
RM0011512 	MICROWAVE
RM0011513 	TV
RM0011513 	COFFEE_MAKER
RM0011513 	WIFI
RM0011513 	FRIDGE
RM0011513 	IRON
RM0011513 	MICROWAVE
RM0011514 	IRON
RM0011514 	HAIRDRYER
RM0011514 	MICROWAVE
RM0011514 	COFFEE_MAKER
RM0011514 	MINIBAR
RM0011514 	SAFE
RM0011514 	FRIDGE
RM0011514 	TV
RM0011515 	MINIBAR
RM0011515 	AIR_CONDITION
RM0011515 	WIFI
RM0011515 	IRON
RM0011515 	TV
RM0011515 	HAIRDRYER
RM0011515 	FRIDGE
RM0011516 	TV
RM0011516 	FRIDGE
RM0011516 	COFFEE_MAKER
RM0011516 	AIR_CONDITION
RM0011516 	DESK
RM0011516 	MINIBAR
RM0011516 	HAIRDRYER
RM0011516 	IRON
RM0011517 	HAIRDRYER
RM0011517 	AIR_CONDITION
RM0011517 	COFFEE_MAKER
RM0011600 	WIFI
RM0011600 	MINIBAR
RM0011600 	AIR_CONDITION
RM0011600 	MICROWAVE
RM0011601 	TV
RM0011601 	MICROWAVE
RM0011601 	DESK
RM0011601 	FRIDGE
RM0011601 	MINIBAR
RM0011601 	HAIRDRYER
RM0011601 	AIR_CONDITION
RM0011601 	SAFE
RM0011601 	IRON
RM0011602 	FRIDGE
RM0011602 	MICROWAVE
RM0011602 	MINIBAR
RM0011602 	HAIRDRYER
RM0011602 	COFFEE_MAKER
RM0011602 	TV
RM0011602 	WIFI
RM0011602 	SAFE
RM0011603 	DESK
RM0011603 	MINIBAR
RM0011603 	MICROWAVE
RM0011603 	TV
RM0011603 	AIR_CONDITION
RM0011603 	FRIDGE
RM0011603 	SAFE
RM0011603 	COFFEE_MAKER
RM0011603 	HAIRDRYER
RM0011604 	TV
RM0011604 	DESK
RM0011604 	IRON
RM0011604 	MINIBAR
RM0011605 	SAFE
RM0011605 	HAIRDRYER
RM0011605 	AIR_CONDITION
RM0011605 	COFFEE_MAKER
RM0011606 	HAIRDRYER
RM0011606 	AIR_CONDITION
RM0011606 	FRIDGE
RM0011606 	IRON
RM0011606 	MINIBAR
RM0011607 	FRIDGE
RM0011607 	WIFI
RM0011607 	HAIRDRYER
RM0011607 	TV
RM0011608 	AIR_CONDITION
RM0011608 	DESK
RM0011608 	TV
RM0011608 	MICROWAVE
RM0011608 	HAIRDRYER
RM0011608 	SAFE
RM0011608 	FRIDGE
RM0011609 	WIFI
RM0011609 	AIR_CONDITION
RM0011609 	COFFEE_MAKER
RM0011610 	FRIDGE
RM0011610 	WIFI
RM0011610 	COFFEE_MAKER
RM0011610 	MICROWAVE
RM0011610 	DESK
RM0011610 	TV
RM0011610 	IRON
RM0011610 	AIR_CONDITION
RM0011610 	MINIBAR
RM0011610 	HAIRDRYER
RM0011610 	SAFE
RM0011611 	MINIBAR
RM0011611 	WIFI
RM0011611 	AIR_CONDITION
RM0011611 	HAIRDRYER
RM0011611 	MICROWAVE
RM0011611 	IRON
RM0011611 	FRIDGE
RM0011611 	TV
RM0011611 	DESK
RM0011611 	COFFEE_MAKER
RM0011611 	SAFE
RM0011612 	AIR_CONDITION
RM0011612 	COFFEE_MAKER
RM0011612 	FRIDGE
RM0011612 	HAIRDRYER
RM0011613 	DESK
RM0011613 	HAIRDRYER
RM0011613 	COFFEE_MAKER
RM0011613 	TV
RM0011613 	IRON
RM0011613 	FRIDGE
RM0011613 	SAFE
RM0011613 	MICROWAVE
RM0011613 	MINIBAR
RM0011613 	AIR_CONDITION
RM0011614 	AIR_CONDITION
RM0011614 	MINIBAR
RM0011614 	IRON
RM0011614 	DESK
RM0011614 	HAIRDRYER
RM0011614 	WIFI
RM0011614 	MICROWAVE
RM0011614 	SAFE
RM0011615 	TV
RM0011616 	AIR_CONDITION
RM0011616 	COFFEE_MAKER
RM0011616 	WIFI
RM0011616 	HAIRDRYER
RM0011616 	IRON
RM0011617 	AIR_CONDITION
RM0011617 	SAFE
RM0011617 	COFFEE_MAKER
RM0011617 	TV
RM0011617 	IRON
RM0011617 	MICROWAVE
RM0011700 	TV
RM0011700 	DESK
RM0011700 	HAIRDRYER
RM0011700 	FRIDGE
RM0011701 	FRIDGE
RM0011701 	COFFEE_MAKER
RM0011702 	DESK
RM0011702 	HAIRDRYER
RM0011703 	FRIDGE
RM0011703 	MINIBAR
RM0011703 	MICROWAVE
RM0011703 	SAFE
RM0011703 	COFFEE_MAKER
RM0011703 	HAIRDRYER
RM0011704 	HAIRDRYER
RM0011704 	MINIBAR
RM0011705 	HAIRDRYER
RM0011705 	WIFI
RM0011705 	DESK
RM0011705 	MINIBAR
RM0011705 	TV
RM0011705 	MICROWAVE
RM0011706 	DESK
RM0011706 	MINIBAR
RM0011706 	HAIRDRYER
RM0011706 	IRON
RM0011706 	AIR_CONDITION
RM0011706 	TV
RM0011706 	COFFEE_MAKER
RM0011706 	MICROWAVE
RM0011706 	SAFE
RM0011707 	TV
RM0011707 	WIFI
RM0011707 	MINIBAR
RM0011707 	FRIDGE
RM0011707 	SAFE
RM0011707 	COFFEE_MAKER
RM0011707 	AIR_CONDITION
RM0011707 	MICROWAVE
RM0011707 	HAIRDRYER
RM0011708 	FRIDGE
RM0011708 	COFFEE_MAKER
RM0011708 	MINIBAR
RM0011709 	SAFE
RM0011709 	HAIRDRYER
RM0011709 	FRIDGE
RM0011709 	AIR_CONDITION
RM0011709 	TV
RM0011709 	WIFI
RM0011709 	DESK
RM0011710 	SAFE
RM0011710 	COFFEE_MAKER
RM0011710 	MICROWAVE
RM0011710 	WIFI
RM0011710 	MINIBAR
RM0011710 	FRIDGE
RM0011711 	HAIRDRYER
RM0011711 	FRIDGE
RM0011711 	DESK
RM0011711 	MINIBAR
RM0011711 	SAFE
RM0011711 	COFFEE_MAKER
RM0011712 	DESK
RM0011712 	HAIRDRYER
RM0011712 	FRIDGE
RM0011712 	MINIBAR
RM0011712 	TV
RM0011712 	SAFE
RM0011712 	IRON
RM0011712 	COFFEE_MAKER
RM0011712 	MICROWAVE
RM0011712 	WIFI
RM0011713 	TV
RM0011713 	AIR_CONDITION
RM0011713 	SAFE
RM0011713 	FRIDGE
RM0011713 	WIFI
RM0011714 	FRIDGE
RM0011714 	WIFI
RM0011714 	HAIRDRYER
RM0011714 	DESK
RM0011714 	MINIBAR
RM0011714 	MICROWAVE
RM0011714 	TV
RM0011714 	COFFEE_MAKER
RM0011800 	FRIDGE
RM0011800 	IRON
RM0011800 	HAIRDRYER
RM0011800 	SAFE
RM0011800 	DESK
RM0011800 	AIR_CONDITION
RM0011800 	COFFEE_MAKER
RM0011800 	TV
RM0011800 	MINIBAR
RM0011800 	WIFI
RM0011800 	MICROWAVE
RM0011801 	FRIDGE
RM0011801 	HAIRDRYER
RM0011801 	SAFE
RM0011801 	MINIBAR
RM0011801 	COFFEE_MAKER
RM0011801 	AIR_CONDITION
RM0011801 	MICROWAVE
RM0011801 	TV
RM0011801 	IRON
RM0011801 	DESK
RM0011801 	WIFI
RM0011802 	HAIRDRYER
RM0011802 	MINIBAR
RM0011802 	IRON
RM0011802 	WIFI
RM0011802 	FRIDGE
RM0011802 	AIR_CONDITION
RM0011803 	IRON
RM0011803 	WIFI
RM0011803 	COFFEE_MAKER
RM0011804 	IRON
RM0011804 	FRIDGE
RM0011804 	MICROWAVE
RM0011804 	SAFE
RM0011804 	TV
RM0011804 	AIR_CONDITION
RM0011804 	DESK
RM0011804 	WIFI
RM0011804 	HAIRDRYER
RM0011805 	HAIRDRYER
RM0011805 	COFFEE_MAKER
RM0011805 	TV
RM0011806 	MICROWAVE
RM0011806 	TV
RM0011806 	AIR_CONDITION
RM0011806 	WIFI
RM0011806 	FRIDGE
RM0011806 	IRON
RM0011806 	DESK
RM0011806 	SAFE
RM0011807 	HAIRDRYER
RM0011807 	SAFE
RM0011807 	IRON
RM0011808 	HAIRDRYER
RM0011809 	SAFE
RM0011809 	MICROWAVE
RM0011809 	AIR_CONDITION
RM0011809 	DESK
RM0011809 	FRIDGE
RM0011809 	COFFEE_MAKER
RM0011809 	MINIBAR
RM0011809 	TV
RM0011809 	IRON
RM0011809 	HAIRDRYER
RM0011810 	COFFEE_MAKER
RM0011810 	DESK
RM0011810 	SAFE
RM0011810 	HAIRDRYER
RM0011810 	MICROWAVE
RM0011810 	MINIBAR
RM0011810 	AIR_CONDITION
RM0011811 	TV
RM0011811 	MICROWAVE
RM0011811 	DESK
RM0011811 	FRIDGE
RM0011811 	COFFEE_MAKER
RM0011811 	IRON
RM0011811 	WIFI
RM0011900 	IRON
RM0011900 	AIR_CONDITION
RM0011900 	TV
RM0011900 	FRIDGE
RM0011901 	FRIDGE
RM0011901 	MICROWAVE
RM0011902 	HAIRDRYER
RM0011902 	SAFE
RM0011902 	AIR_CONDITION
RM0011902 	FRIDGE
RM0011902 	WIFI
RM0011902 	TV
RM0011902 	COFFEE_MAKER
RM0011903 	SAFE
RM0011903 	COFFEE_MAKER
RM0011903 	MINIBAR
RM0011903 	TV
RM0011903 	AIR_CONDITION
RM0011903 	IRON
RM0011903 	WIFI
RM0011904 	DESK
RM0011905 	TV
RM0011905 	SAFE
RM0011905 	MICROWAVE
RM0011905 	IRON
RM0011905 	WIFI
RM0011905 	MINIBAR
RM0011905 	HAIRDRYER
RM0011906 	TV
RM0011906 	COFFEE_MAKER
RM0011906 	DESK
RM0011906 	FRIDGE
RM0011906 	AIR_CONDITION
RM0011906 	SAFE
RM0011906 	MINIBAR
RM0011906 	HAIRDRYER
RM0011906 	IRON
RM0011906 	WIFI
RM0011906 	MICROWAVE
RM0011907 	AIR_CONDITION
RM0011907 	MINIBAR
RM0011908 	FRIDGE
RM0011909 	FRIDGE
RM0011909 	IRON
RM0011909 	MINIBAR
RM0011909 	COFFEE_MAKER
RM0011910 	HAIRDRYER
RM0011910 	MINIBAR
RM0011910 	AIR_CONDITION
RM0011910 	COFFEE_MAKER
RM0011910 	DESK
RM0011910 	IRON
RM0011910 	MICROWAVE
RM0011910 	WIFI
RM0012000 	HAIRDRYER
RM0012000 	AIR_CONDITION
RM0012000 	WIFI
RM0012000 	SAFE
RM0012000 	DESK
RM0012000 	IRON
RM0012000 	TV
RM0012000 	FRIDGE
RM0012001 	MINIBAR
RM0012001 	WIFI
RM0012001 	FRIDGE
RM0012001 	SAFE
RM0012002 	TV
RM0012002 	MICROWAVE
RM0012002 	COFFEE_MAKER
RM0012002 	SAFE
RM0012002 	WIFI
RM0012002 	DESK
RM0012002 	HAIRDRYER
RM0012002 	FRIDGE
RM0012002 	AIR_CONDITION
RM0012002 	MINIBAR
RM0012002 	IRON
RM0012003 	COFFEE_MAKER
RM0012003 	HAIRDRYER
RM0012003 	FRIDGE
RM0012003 	AIR_CONDITION
RM0012003 	WIFI
RM0012003 	MICROWAVE
RM0012004 	FRIDGE
RM0012004 	MINIBAR
RM0012004 	COFFEE_MAKER
RM0012004 	DESK
RM0012005 	FRIDGE
RM0012005 	COFFEE_MAKER
RM0012005 	MINIBAR
RM0012005 	TV
RM0012005 	SAFE
RM0012005 	WIFI
RM0012005 	DESK
RM0012005 	MICROWAVE
RM0012005 	IRON
RM0012005 	AIR_CONDITION
RM0012006 	DESK
RM0012006 	HAIRDRYER
RM0012006 	TV
RM0012006 	MICROWAVE
RM0012006 	COFFEE_MAKER
RM0012007 	SAFE
RM0012007 	MINIBAR
RM0012007 	FRIDGE
RM0012007 	TV
RM0012007 	MICROWAVE
RM0012007 	IRON
RM0012007 	DESK
RM0012007 	WIFI
RM0012008 	IRON
RM0012008 	MINIBAR
RM0012008 	WIFI
RM0012008 	AIR_CONDITION
RM0012008 	MICROWAVE
RM0012008 	DESK
RM0012008 	SAFE
RM0012008 	COFFEE_MAKER
RM0012008 	TV
RM0012008 	HAIRDRYER
RM0012009 	DESK
RM0012009 	SAFE
RM0012009 	AIR_CONDITION
RM0012009 	IRON
RM0012009 	MICROWAVE
RM0012009 	COFFEE_MAKER
RM0012009 	FRIDGE
RM0012009 	WIFI
RM0012010 	FRIDGE
RM0012010 	IRON
RM0012010 	SAFE
RM0012010 	MICROWAVE
RM0012010 	MINIBAR
RM0012010 	TV
RM0012010 	DESK
RM0012010 	WIFI
RM0012011 	COFFEE_MAKER
RM0012011 	TV
RM0012011 	DESK
RM0012011 	MINIBAR
RM0012011 	HAIRDRYER
RM0012011 	IRON
RM0012011 	AIR_CONDITION
RM0012100 	COFFEE_MAKER
RM0012100 	DESK
RM0012100 	FRIDGE
RM0012100 	TV
RM0012100 	MICROWAVE
RM0012100 	IRON
RM0012100 	SAFE
RM0012100 	MINIBAR
RM0012100 	HAIRDRYER
RM0012100 	AIR_CONDITION
RM0012100 	WIFI
RM0012101 	TV
RM0012101 	IRON
RM0012101 	FRIDGE
RM0012101 	WIFI
RM0012101 	AIR_CONDITION
RM0012101 	DESK
RM0012101 	SAFE
RM0012101 	COFFEE_MAKER
RM0012101 	MICROWAVE
RM0012102 	MINIBAR
RM0012103 	WIFI
RM0012104 	MINIBAR
RM0012104 	AIR_CONDITION
RM0012104 	HAIRDRYER
RM0012104 	SAFE
RM0012104 	DESK
RM0012104 	IRON
RM0012104 	WIFI
RM0012104 	TV
RM0012105 	DESK
RM0012105 	HAIRDRYER
RM0012105 	IRON
RM0012106 	MICROWAVE
RM0012106 	FRIDGE
RM0012106 	AIR_CONDITION
RM0012106 	DESK
RM0012106 	SAFE
RM0012106 	WIFI
RM0012106 	IRON
RM0012106 	COFFEE_MAKER
RM0012107 	TV
RM0012107 	AIR_CONDITION
RM0012107 	HAIRDRYER
RM0012107 	FRIDGE
RM0012107 	WIFI
RM0012107 	DESK
RM0012108 	FRIDGE
RM0012108 	TV
RM0012108 	COFFEE_MAKER
RM0012108 	DESK
RM0012108 	SAFE
RM0012108 	AIR_CONDITION
RM0012108 	MINIBAR
RM0012108 	WIFI
RM0012108 	MICROWAVE
RM0012109 	HAIRDRYER
RM0012110 	DESK
RM0012110 	TV
RM0012110 	FRIDGE
RM0012111 	MINIBAR
RM0012111 	FRIDGE
RM0012111 	WIFI
RM0012111 	SAFE
RM0012111 	MICROWAVE
RM0012111 	IRON
RM0012111 	DESK
RM0012111 	TV
RM0012111 	COFFEE_MAKER
RM0012112 	COFFEE_MAKER
RM0012112 	IRON
RM0012200 	TV
RM0012200 	AIR_CONDITION
RM0012200 	DESK
RM0012200 	WIFI
RM0012200 	SAFE
RM0012200 	MICROWAVE
RM0012200 	FRIDGE
RM0012200 	COFFEE_MAKER
RM0012201 	MICROWAVE
RM0012201 	SAFE
RM0012201 	IRON
RM0012201 	DESK
RM0012202 	COFFEE_MAKER
RM0012203 	AIR_CONDITION
RM0012203 	DESK
RM0012203 	HAIRDRYER
RM0012203 	COFFEE_MAKER
RM0012204 	DESK
RM0012204 	TV
RM0012204 	MICROWAVE
RM0012204 	FRIDGE
RM0012204 	IRON
RM0012204 	HAIRDRYER
RM0012204 	SAFE
RM0012204 	WIFI
RM0012204 	MINIBAR
RM0012205 	WIFI
RM0012206 	DESK
RM0012206 	SAFE
RM0012206 	MICROWAVE
RM0012207 	HAIRDRYER
RM0012207 	IRON
RM0012207 	FRIDGE
RM0012207 	MICROWAVE
RM0012207 	MINIBAR
RM0012207 	DESK
RM0012207 	COFFEE_MAKER
RM0012208 	AIR_CONDITION
RM0012208 	IRON
RM0012208 	HAIRDRYER
RM0012208 	SAFE
RM0012208 	MINIBAR
RM0012208 	DESK
RM0012208 	COFFEE_MAKER
RM0012208 	TV
RM0012208 	WIFI
RM0012208 	MICROWAVE
RM0012208 	FRIDGE
RM0012209 	IRON
RM0012209 	HAIRDRYER
RM0012209 	WIFI
RM0012209 	SAFE
RM0012209 	MICROWAVE
RM0012209 	TV
RM0012209 	AIR_CONDITION
RM0012210 	WIFI
RM0012210 	DESK
RM0012210 	TV
RM0012210 	IRON
RM0012210 	SAFE
RM0012210 	MINIBAR
RM0012210 	COFFEE_MAKER
RM0012210 	FRIDGE
RM0012210 	HAIRDRYER
RM0012211 	WIFI
RM0012211 	FRIDGE
RM0012211 	MICROWAVE
RM0012211 	AIR_CONDITION
RM0012211 	DESK
RM0012211 	TV
RM0012211 	HAIRDRYER
RM0012212 	AIR_CONDITION
RM0012212 	MINIBAR
RM0012212 	HAIRDRYER
RM0012212 	WIFI
RM0012212 	IRON
RM0012212 	FRIDGE
RM0012212 	MICROWAVE
RM0012213 	HAIRDRYER
RM0012213 	DESK
RM0012213 	FRIDGE
RM0012214 	MINIBAR
RM0012214 	HAIRDRYER
RM0012214 	IRON
RM0012214 	DESK
RM0012214 	MICROWAVE
RM0012214 	COFFEE_MAKER
RM0012214 	FRIDGE
RM0012214 	AIR_CONDITION
RM0012214 	TV
RM0012214 	WIFI
RM0012215 	WIFI
RM0012215 	COFFEE_MAKER
RM0012215 	TV
RM0012215 	DESK
RM0012215 	SAFE
RM0012215 	FRIDGE
RM0012215 	MICROWAVE
RM0012215 	HAIRDRYER
RM0012216 	COFFEE_MAKER
RM0012216 	AIR_CONDITION
RM0012216 	TV
RM0020000 	MICROWAVE
RM0020000 	AIR_CONDITION
RM0020000 	DESK
RM0020000 	COFFEE_MAKER
RM0020001 	SAFE
RM0020002 	COFFEE_MAKER
RM0020002 	WIFI
RM0020002 	AIR_CONDITION
RM0020002 	TV
RM0020002 	MINIBAR
RM0020002 	MICROWAVE
RM0020002 	DESK
RM0020002 	IRON
RM0020002 	HAIRDRYER
RM0020002 	FRIDGE
RM0020002 	SAFE
RM0020003 	SAFE
RM0020003 	TV
RM0020003 	COFFEE_MAKER
RM0020003 	MICROWAVE
RM0020003 	WIFI
RM0020004 	AIR_CONDITION
RM0020004 	HAIRDRYER
RM0020004 	WIFI
RM0020004 	DESK
RM0020004 	TV
RM0020004 	IRON
RM0020004 	COFFEE_MAKER
RM0020005 	MINIBAR
RM0020005 	AIR_CONDITION
RM0020005 	COFFEE_MAKER
RM0020005 	SAFE
RM0020006 	AIR_CONDITION
RM0020006 	WIFI
RM0020007 	AIR_CONDITION
RM0020007 	WIFI
RM0020007 	TV
RM0020007 	FRIDGE
RM0020007 	SAFE
RM0020007 	MICROWAVE
RM0020008 	COFFEE_MAKER
RM0020008 	TV
RM0020008 	MINIBAR
RM0020008 	SAFE
RM0020008 	MICROWAVE
RM0020008 	HAIRDRYER
RM0020008 	DESK
RM0020008 	FRIDGE
RM0020008 	IRON
RM0020009 	WIFI
RM0020009 	MICROWAVE
RM0020009 	IRON
RM0020009 	DESK
RM0020100 	FRIDGE
RM0020100 	HAIRDRYER
RM0020100 	DESK
RM0020100 	TV
RM0020100 	AIR_CONDITION
RM0020101 	COFFEE_MAKER
RM0020101 	DESK
RM0020101 	WIFI
RM0020101 	TV
RM0020101 	FRIDGE
RM0020101 	MICROWAVE
RM0020101 	AIR_CONDITION
RM0020102 	TV
RM0020102 	DESK
RM0020102 	FRIDGE
RM0020102 	HAIRDRYER
RM0020102 	SAFE
RM0020103 	FRIDGE
RM0020103 	MICROWAVE
RM0020103 	HAIRDRYER
RM0020104 	COFFEE_MAKER
RM0020104 	DESK
RM0020104 	TV
RM0020104 	HAIRDRYER
RM0020104 	FRIDGE
RM0020105 	MICROWAVE
RM0020105 	FRIDGE
RM0020105 	HAIRDRYER
RM0020106 	WIFI
RM0020106 	MICROWAVE
RM0020106 	TV
RM0020106 	HAIRDRYER
RM0020106 	IRON
RM0020106 	MINIBAR
RM0020106 	DESK
RM0020106 	AIR_CONDITION
RM0020106 	SAFE
RM0020107 	DESK
RM0020107 	TV
RM0020107 	HAIRDRYER
RM0020107 	WIFI
RM0020107 	COFFEE_MAKER
RM0020108 	TV
RM0020108 	SAFE
RM0020109 	FRIDGE
RM0020109 	IRON
RM0020109 	SAFE
RM0020109 	MICROWAVE
RM0020109 	MINIBAR
RM0020109 	AIR_CONDITION
RM0020109 	COFFEE_MAKER
RM0020109 	WIFI
RM0020109 	DESK
RM0020110 	SAFE
RM0020110 	AIR_CONDITION
RM0020110 	WIFI
RM0020110 	MINIBAR
RM0020110 	IRON
RM0020110 	HAIRDRYER
RM0020110 	COFFEE_MAKER
RM0020110 	MICROWAVE
RM0020110 	TV
RM0020110 	DESK
RM0020110 	FRIDGE
RM0020111 	MINIBAR
RM0020111 	COFFEE_MAKER
RM0020111 	WIFI
RM0020111 	MICROWAVE
RM0020111 	AIR_CONDITION
RM0020112 	HAIRDRYER
RM0020112 	TV
RM0020112 	DESK
RM0020112 	FRIDGE
RM0020112 	WIFI
RM0020112 	SAFE
RM0020112 	MINIBAR
RM0020113 	SAFE
RM0020113 	MINIBAR
RM0020113 	TV
RM0020113 	DESK
RM0020113 	WIFI
RM0020113 	HAIRDRYER
RM0020113 	IRON
RM0020114 	SAFE
RM0020114 	IRON
RM0020115 	IRON
RM0020116 	SAFE
RM0020116 	AIR_CONDITION
RM0020116 	MICROWAVE
RM0020116 	DESK
RM0020116 	TV
RM0020116 	IRON
RM0020116 	FRIDGE
RM0020116 	WIFI
RM0020116 	COFFEE_MAKER
RM0020116 	HAIRDRYER
RM0020117 	DESK
RM0020117 	SAFE
RM0020118 	MICROWAVE
RM0020118 	MINIBAR
RM0020118 	COFFEE_MAKER
RM0020118 	TV
RM0020118 	AIR_CONDITION
RM0020118 	FRIDGE
RM0020118 	IRON
RM0020118 	WIFI
RM0020118 	HAIRDRYER
RM0020118 	DESK
RM0020118 	SAFE
RM0020200 	COFFEE_MAKER
RM0020200 	SAFE
RM0020201 	HAIRDRYER
RM0020201 	DESK
RM0020201 	COFFEE_MAKER
RM0020201 	MICROWAVE
RM0020202 	FRIDGE
RM0020202 	WIFI
RM0020202 	IRON
RM0020202 	HAIRDRYER
RM0020202 	MICROWAVE
RM0020203 	SAFE
RM0020203 	MICROWAVE
RM0020203 	COFFEE_MAKER
RM0020203 	TV
RM0020203 	DESK
RM0020203 	MINIBAR
RM0020203 	AIR_CONDITION
RM0020203 	WIFI
RM0020203 	IRON
RM0020204 	FRIDGE
RM0020204 	WIFI
RM0020204 	COFFEE_MAKER
RM0020204 	MINIBAR
RM0020204 	MICROWAVE
RM0020205 	IRON
RM0020205 	SAFE
RM0020205 	COFFEE_MAKER
RM0020205 	DESK
RM0020205 	FRIDGE
RM0020205 	HAIRDRYER
RM0020205 	AIR_CONDITION
RM0020205 	WIFI
RM0020205 	MICROWAVE
RM0020205 	MINIBAR
RM0020205 	TV
RM0020206 	AIR_CONDITION
RM0020206 	COFFEE_MAKER
RM0020206 	SAFE
RM0020206 	MINIBAR
RM0020206 	IRON
RM0020206 	FRIDGE
RM0020206 	HAIRDRYER
RM0020207 	DESK
RM0020207 	HAIRDRYER
RM0020207 	SAFE
RM0020207 	MICROWAVE
RM0020208 	FRIDGE
RM0020208 	HAIRDRYER
RM0020208 	MICROWAVE
RM0020209 	IRON
RM0020209 	COFFEE_MAKER
RM0020209 	HAIRDRYER
RM0020209 	MICROWAVE
RM0020209 	DESK
RM0020209 	SAFE
RM0020209 	FRIDGE
RM0020210 	DESK
RM0020210 	COFFEE_MAKER
RM0020210 	TV
RM0020211 	HAIRDRYER
RM0020211 	AIR_CONDITION
RM0020211 	SAFE
RM0020212 	FRIDGE
RM0020212 	WIFI
RM0020212 	COFFEE_MAKER
RM0020212 	MINIBAR
RM0020212 	AIR_CONDITION
RM0020212 	SAFE
RM0020212 	DESK
RM0020212 	HAIRDRYER
RM0020212 	TV
RM0020213 	AIR_CONDITION
RM0020213 	TV
RM0020213 	COFFEE_MAKER
RM0020213 	SAFE
RM0020213 	DESK
RM0020213 	MINIBAR
RM0020213 	FRIDGE
RM0020213 	HAIRDRYER
RM0020213 	IRON
RM0020214 	WIFI
RM0020214 	MICROWAVE
RM0020214 	IRON
RM0020214 	COFFEE_MAKER
RM0020214 	FRIDGE
RM0020214 	AIR_CONDITION
RM0020214 	TV
RM0020214 	HAIRDRYER
RM0020215 	HAIRDRYER
RM0020215 	MICROWAVE
RM0020215 	FRIDGE
RM0020215 	SAFE
RM0020215 	IRON
RM0020215 	DESK
RM0020215 	COFFEE_MAKER
RM0020215 	AIR_CONDITION
RM0020215 	TV
RM0020215 	WIFI
RM0020216 	COFFEE_MAKER
RM0020216 	AIR_CONDITION
RM0020216 	IRON
RM0020216 	WIFI
RM0020216 	DESK
RM0020300 	HAIRDRYER
RM0020300 	TV
RM0020300 	WIFI
RM0020300 	IRON
RM0020300 	FRIDGE
RM0020300 	MINIBAR
RM0020300 	MICROWAVE
RM0020300 	AIR_CONDITION
RM0020300 	DESK
RM0020301 	TV
RM0020301 	FRIDGE
RM0020301 	DESK
RM0020301 	WIFI
RM0020301 	AIR_CONDITION
RM0020302 	DESK
RM0020302 	MINIBAR
RM0020302 	WIFI
RM0020302 	COFFEE_MAKER
RM0020302 	TV
RM0020302 	SAFE
RM0020302 	MICROWAVE
RM0020303 	DESK
RM0020303 	FRIDGE
RM0020303 	WIFI
RM0020303 	SAFE
RM0020303 	MICROWAVE
RM0020303 	HAIRDRYER
RM0020303 	COFFEE_MAKER
RM0020303 	AIR_CONDITION
RM0020303 	MINIBAR
RM0020303 	IRON
RM0020304 	DESK
RM0020304 	FRIDGE
RM0020304 	TV
RM0020304 	MICROWAVE
RM0020304 	HAIRDRYER
RM0020304 	COFFEE_MAKER
RM0020304 	IRON
RM0020305 	SAFE
RM0020305 	HAIRDRYER
RM0020305 	AIR_CONDITION
RM0020305 	WIFI
RM0020306 	SAFE
RM0020306 	FRIDGE
RM0020306 	AIR_CONDITION
RM0020306 	HAIRDRYER
RM0020306 	WIFI
RM0020306 	MINIBAR
RM0020306 	IRON
RM0020306 	DESK
RM0020306 	COFFEE_MAKER
RM0020306 	MICROWAVE
RM0020307 	SAFE
RM0020307 	AIR_CONDITION
RM0020307 	IRON
RM0020307 	DESK
RM0020307 	COFFEE_MAKER
RM0020308 	IRON
RM0020308 	TV
RM0020308 	HAIRDRYER
RM0020308 	SAFE
RM0020309 	TV
RM0020309 	WIFI
RM0020309 	AIR_CONDITION
RM0020309 	FRIDGE
RM0020309 	HAIRDRYER
RM0020310 	MINIBAR
RM0020310 	FRIDGE
RM0020311 	MINIBAR
RM0020311 	TV
RM0020311 	COFFEE_MAKER
RM0020311 	IRON
RM0020311 	MICROWAVE
RM0020312 	WIFI
RM0020312 	HAIRDRYER
RM0020312 	TV
RM0020312 	MINIBAR
RM0020313 	AIR_CONDITION
RM0020313 	HAIRDRYER
RM0020313 	COFFEE_MAKER
RM0020313 	MINIBAR
RM0020313 	SAFE
RM0020313 	IRON
RM0020313 	WIFI
RM0020313 	MICROWAVE
RM0020314 	FRIDGE
RM0020314 	TV
RM0020314 	AIR_CONDITION
RM0020314 	MINIBAR
RM0020314 	COFFEE_MAKER
RM0020314 	IRON
RM0020315 	HAIRDRYER
RM0020316 	FRIDGE
RM0020316 	IRON
RM0020316 	COFFEE_MAKER
RM0020316 	DESK
RM0020316 	WIFI
RM0020316 	MICROWAVE
RM0020316 	TV
RM0020316 	SAFE
RM0020316 	AIR_CONDITION
RM0020316 	HAIRDRYER
RM0020317 	TV
RM0020317 	FRIDGE
RM0020317 	WIFI
RM0020317 	AIR_CONDITION
RM0020317 	SAFE
RM0020317 	HAIRDRYER
RM0020317 	DESK
RM0020317 	MINIBAR
RM0020317 	COFFEE_MAKER
RM0020317 	IRON
RM0020400 	IRON
RM0020400 	AIR_CONDITION
RM0020400 	TV
RM0020401 	FRIDGE
RM0020401 	DESK
RM0020401 	COFFEE_MAKER
RM0020401 	MINIBAR
RM0020401 	AIR_CONDITION
RM0020401 	SAFE
RM0020401 	WIFI
RM0020402 	MINIBAR
RM0020402 	COFFEE_MAKER
RM0020402 	IRON
RM0020402 	FRIDGE
RM0020402 	DESK
RM0020403 	TV
RM0020403 	AIR_CONDITION
RM0020403 	FRIDGE
RM0020403 	SAFE
RM0020403 	COFFEE_MAKER
RM0020403 	MINIBAR
RM0020403 	WIFI
RM0020403 	DESK
RM0020403 	IRON
RM0020403 	MICROWAVE
RM0020404 	SAFE
RM0020404 	IRON
RM0020404 	HAIRDRYER
RM0020404 	MINIBAR
RM0020404 	MICROWAVE
RM0020404 	WIFI
RM0020405 	MICROWAVE
RM0020405 	HAIRDRYER
RM0020405 	AIR_CONDITION
RM0020405 	WIFI
RM0020405 	TV
RM0020405 	DESK
RM0020405 	FRIDGE
RM0020405 	COFFEE_MAKER
RM0020405 	IRON
RM0020405 	SAFE
RM0020405 	MINIBAR
RM0020406 	MINIBAR
RM0020406 	IRON
RM0020406 	MICROWAVE
RM0020406 	DESK
RM0020406 	HAIRDRYER
RM0020406 	SAFE
RM0020406 	WIFI
RM0020406 	FRIDGE
RM0020406 	AIR_CONDITION
RM0020406 	TV
RM0020406 	COFFEE_MAKER
RM0020407 	AIR_CONDITION
RM0020407 	IRON
RM0020407 	HAIRDRYER
RM0020407 	DESK
RM0020407 	TV
RM0020408 	MINIBAR
RM0020408 	SAFE
RM0020408 	AIR_CONDITION
RM0020408 	COFFEE_MAKER
RM0020408 	IRON
RM0020408 	FRIDGE
RM0020408 	TV
RM0020409 	TV
RM0020409 	DESK
RM0020409 	MINIBAR
RM0020409 	COFFEE_MAKER
RM0020409 	IRON
RM0020409 	AIR_CONDITION
RM0020409 	FRIDGE
RM0020409 	HAIRDRYER
RM0020409 	MICROWAVE
RM0020409 	WIFI
RM0020409 	SAFE
RM0020410 	DESK
RM0020410 	AIR_CONDITION
RM0020410 	SAFE
RM0020410 	WIFI
RM0020410 	MICROWAVE
RM0020410 	IRON
RM0020410 	TV
RM0020410 	FRIDGE
RM0020410 	MINIBAR
RM0020410 	HAIRDRYER
RM0020410 	COFFEE_MAKER
RM0020411 	AIR_CONDITION
RM0020411 	MICROWAVE
RM0020411 	TV
RM0020411 	IRON
RM0020411 	COFFEE_MAKER
RM0020411 	SAFE
RM0020411 	MINIBAR
RM0020411 	HAIRDRYER
RM0020411 	DESK
RM0020500 	IRON
RM0020500 	MICROWAVE
RM0020500 	TV
RM0020500 	FRIDGE
RM0020500 	MINIBAR
RM0020500 	COFFEE_MAKER
RM0020500 	DESK
RM0020500 	HAIRDRYER
RM0020501 	IRON
RM0020501 	HAIRDRYER
RM0020501 	MINIBAR
RM0020501 	AIR_CONDITION
RM0020501 	FRIDGE
RM0020501 	SAFE
RM0020501 	COFFEE_MAKER
RM0020501 	DESK
RM0020501 	WIFI
RM0020501 	MICROWAVE
RM0020501 	TV
RM0020502 	IRON
RM0020503 	WIFI
RM0020503 	FRIDGE
RM0020503 	MINIBAR
RM0020503 	AIR_CONDITION
RM0020503 	MICROWAVE
RM0020503 	SAFE
RM0020503 	COFFEE_MAKER
RM0020503 	TV
RM0020504 	FRIDGE
RM0020504 	MICROWAVE
RM0020504 	TV
RM0020504 	COFFEE_MAKER
RM0020504 	DESK
RM0020504 	SAFE
RM0020504 	WIFI
RM0020504 	MINIBAR
RM0020505 	MICROWAVE
RM0020505 	HAIRDRYER
RM0020505 	WIFI
RM0020505 	COFFEE_MAKER
RM0020505 	DESK
RM0020505 	SAFE
RM0020505 	FRIDGE
RM0020505 	TV
RM0020506 	IRON
RM0020506 	DESK
RM0020506 	MICROWAVE
RM0020506 	TV
RM0020507 	MICROWAVE
RM0020507 	TV
RM0020507 	WIFI
RM0020507 	IRON
RM0020507 	HAIRDRYER
RM0020507 	SAFE
RM0020507 	FRIDGE
RM0020507 	AIR_CONDITION
RM0020508 	SAFE
RM0020508 	FRIDGE
RM0020508 	MICROWAVE
RM0020508 	IRON
RM0020508 	WIFI
RM0020508 	AIR_CONDITION
RM0020508 	HAIRDRYER
RM0020508 	MINIBAR
RM0020508 	DESK
RM0020509 	DESK
RM0020509 	FRIDGE
RM0020509 	AIR_CONDITION
RM0020509 	SAFE
RM0020509 	COFFEE_MAKER
RM0020509 	MICROWAVE
RM0020509 	WIFI
RM0020509 	IRON
RM0020509 	TV
RM0020509 	HAIRDRYER
RM0020510 	DESK
RM0020510 	WIFI
RM0020510 	HAIRDRYER
RM0020510 	SAFE
RM0020510 	AIR_CONDITION
RM0020510 	COFFEE_MAKER
RM0020510 	MICROWAVE
RM0020510 	TV
RM0020511 	COFFEE_MAKER
RM0020511 	WIFI
RM0020511 	TV
RM0020511 	DESK
RM0020511 	MICROWAVE
RM0020511 	HAIRDRYER
RM0020511 	IRON
RM0020511 	MINIBAR
RM0020511 	FRIDGE
RM0020511 	SAFE
RM0020511 	AIR_CONDITION
RM0020512 	MINIBAR
RM0020513 	TV
RM0020514 	MICROWAVE
RM0020514 	WIFI
RM0020514 	SAFE
RM0020514 	AIR_CONDITION
RM0020514 	MINIBAR
RM0020514 	DESK
RM0020514 	HAIRDRYER
RM0020600 	COFFEE_MAKER
RM0020600 	MINIBAR
RM0020600 	WIFI
RM0020601 	MINIBAR
RM0020601 	WIFI
RM0020601 	TV
RM0020601 	HAIRDRYER
RM0020601 	AIR_CONDITION
RM0020602 	DESK
RM0020602 	MICROWAVE
RM0020602 	IRON
RM0020602 	WIFI
RM0020602 	COFFEE_MAKER
RM0020602 	SAFE
RM0020602 	AIR_CONDITION
RM0020602 	TV
RM0020602 	MINIBAR
RM0020603 	DESK
RM0020603 	IRON
RM0020603 	COFFEE_MAKER
RM0020603 	SAFE
RM0020603 	TV
RM0020603 	WIFI
RM0020603 	AIR_CONDITION
RM0020603 	FRIDGE
RM0020603 	MINIBAR
RM0020603 	HAIRDRYER
RM0020604 	COFFEE_MAKER
RM0020604 	MICROWAVE
RM0020604 	DESK
RM0020604 	AIR_CONDITION
RM0020604 	HAIRDRYER
RM0020604 	FRIDGE
RM0020604 	SAFE
RM0020604 	TV
RM0020604 	WIFI
RM0020604 	IRON
RM0020605 	DESK
RM0020606 	TV
RM0020606 	WIFI
RM0020606 	COFFEE_MAKER
RM0020606 	MICROWAVE
RM0020606 	MINIBAR
RM0020606 	SAFE
RM0020606 	AIR_CONDITION
RM0020606 	DESK
RM0020607 	WIFI
RM0020607 	SAFE
RM0020607 	MICROWAVE
RM0020608 	FRIDGE
RM0020608 	IRON
RM0020608 	COFFEE_MAKER
RM0020609 	SAFE
RM0020609 	MINIBAR
RM0020609 	WIFI
RM0020610 	AIR_CONDITION
RM0020611 	AIR_CONDITION
RM0020611 	WIFI
RM0020611 	MICROWAVE
RM0020611 	MINIBAR
RM0020611 	TV
RM0020611 	FRIDGE
RM0020611 	HAIRDRYER
RM0020611 	IRON
RM0020611 	SAFE
RM0020611 	COFFEE_MAKER
RM0020611 	DESK
RM0020612 	MICROWAVE
RM0020612 	AIR_CONDITION
RM0020612 	COFFEE_MAKER
RM0020612 	FRIDGE
RM0020612 	TV
RM0020613 	TV
RM0020613 	SAFE
RM0020613 	WIFI
RM0020613 	HAIRDRYER
RM0020613 	FRIDGE
RM0020613 	MINIBAR
RM0020700 	MICROWAVE
RM0020700 	COFFEE_MAKER
RM0020700 	MINIBAR
RM0020700 	FRIDGE
RM0020700 	HAIRDRYER
RM0020700 	IRON
RM0020700 	DESK
RM0020700 	AIR_CONDITION
RM0020700 	SAFE
RM0020701 	MICROWAVE
RM0020701 	IRON
RM0020701 	AIR_CONDITION
RM0020701 	FRIDGE
RM0020701 	COFFEE_MAKER
RM0020701 	HAIRDRYER
RM0020701 	TV
RM0020701 	WIFI
RM0020702 	DESK
RM0020702 	TV
RM0020702 	IRON
RM0020702 	COFFEE_MAKER
RM0020702 	WIFI
RM0020702 	AIR_CONDITION
RM0020702 	MICROWAVE
RM0020702 	HAIRDRYER
RM0020703 	IRON
RM0020703 	WIFI
RM0020703 	TV
RM0020703 	COFFEE_MAKER
RM0020703 	MICROWAVE
RM0020703 	DESK
RM0020703 	FRIDGE
RM0020703 	HAIRDRYER
RM0020703 	MINIBAR
RM0020704 	TV
RM0020704 	IRON
RM0020705 	MICROWAVE
RM0020705 	MINIBAR
RM0020705 	IRON
RM0020705 	HAIRDRYER
RM0020705 	TV
RM0020705 	DESK
RM0020706 	HAIRDRYER
RM0020706 	COFFEE_MAKER
RM0020706 	TV
RM0020706 	SAFE
RM0020706 	FRIDGE
RM0020706 	DESK
RM0020706 	IRON
RM0020706 	MICROWAVE
RM0020707 	COFFEE_MAKER
RM0020707 	DESK
RM0020708 	TV
RM0020708 	IRON
RM0020708 	MICROWAVE
RM0020708 	WIFI
RM0020708 	HAIRDRYER
RM0020709 	IRON
RM0020709 	FRIDGE
RM0020709 	TV
RM0020709 	MINIBAR
RM0020709 	WIFI
RM0020709 	MICROWAVE
RM0020710 	DESK
RM0020710 	IRON
RM0020710 	WIFI
RM0020710 	FRIDGE
RM0020710 	COFFEE_MAKER
RM0020710 	MINIBAR
RM0020710 	HAIRDRYER
RM0020710 	SAFE
RM0020711 	FRIDGE
RM0020711 	TV
RM0020711 	MICROWAVE
RM0020711 	DESK
RM0020711 	SAFE
RM0020711 	WIFI
RM0020711 	MINIBAR
RM0020712 	COFFEE_MAKER
RM0020712 	MINIBAR
RM0020712 	TV
RM0020712 	FRIDGE
RM0020713 	SAFE
RM0020713 	DESK
RM0020713 	MINIBAR
RM0020713 	AIR_CONDITION
RM0020713 	TV
RM0020713 	COFFEE_MAKER
RM0020713 	IRON
RM0020713 	WIFI
RM0020713 	HAIRDRYER
RM0020713 	FRIDGE
RM0020800 	TV
RM0020800 	MINIBAR
RM0020800 	FRIDGE
RM0020800 	COFFEE_MAKER
RM0020800 	WIFI
RM0020800 	DESK
RM0020800 	SAFE
RM0020801 	COFFEE_MAKER
RM0020801 	AIR_CONDITION
RM0020801 	SAFE
RM0020801 	WIFI
RM0020801 	HAIRDRYER
RM0020802 	SAFE
RM0020802 	HAIRDRYER
RM0020802 	IRON
RM0020802 	WIFI
RM0020802 	AIR_CONDITION
RM0020802 	FRIDGE
RM0020802 	MICROWAVE
RM0020802 	COFFEE_MAKER
RM0020802 	MINIBAR
RM0020803 	MICROWAVE
RM0020803 	DESK
RM0020803 	TV
RM0020803 	MINIBAR
RM0020803 	HAIRDRYER
RM0020803 	IRON
RM0020803 	COFFEE_MAKER
RM0020803 	FRIDGE
RM0020803 	AIR_CONDITION
RM0020803 	WIFI
RM0020804 	DESK
RM0020805 	IRON
RM0020805 	FRIDGE
RM0020805 	MICROWAVE
RM0020805 	COFFEE_MAKER
RM0020805 	HAIRDRYER
RM0020805 	WIFI
RM0020805 	DESK
RM0020805 	SAFE
RM0020806 	WIFI
RM0020806 	TV
RM0020806 	MICROWAVE
RM0020806 	COFFEE_MAKER
RM0020806 	MINIBAR
RM0020806 	IRON
RM0020806 	HAIRDRYER
RM0020806 	AIR_CONDITION
RM0020806 	SAFE
RM0020806 	DESK
RM0020807 	SAFE
RM0020807 	FRIDGE
RM0020807 	MINIBAR
RM0020807 	MICROWAVE
RM0020808 	MINIBAR
RM0020808 	AIR_CONDITION
RM0020808 	IRON
RM0020808 	HAIRDRYER
RM0020808 	FRIDGE
RM0020808 	TV
RM0020808 	WIFI
RM0020808 	DESK
RM0020808 	COFFEE_MAKER
RM0020808 	SAFE
RM0020809 	TV
RM0020809 	MICROWAVE
RM0020809 	SAFE
RM0020809 	FRIDGE
RM0020809 	MINIBAR
RM0020809 	WIFI
RM0020809 	COFFEE_MAKER
RM0020809 	IRON
RM0020809 	AIR_CONDITION
RM0020809 	HAIRDRYER
RM0020809 	DESK
RM0020810 	COFFEE_MAKER
RM0020810 	AIR_CONDITION
RM0020810 	MINIBAR
RM0020810 	SAFE
RM0020810 	FRIDGE
RM0020811 	MICROWAVE
RM0020811 	MINIBAR
RM0020811 	WIFI
RM0020811 	AIR_CONDITION
RM0020811 	SAFE
RM0020811 	COFFEE_MAKER
RM0020811 	IRON
RM0020812 	DESK
RM0020812 	IRON
RM0020812 	COFFEE_MAKER
RM0020813 	TV
RM0020813 	HAIRDRYER
RM0020813 	DESK
RM0020813 	COFFEE_MAKER
RM0020813 	MICROWAVE
RM0020813 	IRON
RM0020813 	SAFE
RM0020813 	WIFI
RM0020814 	MINIBAR
RM0020814 	WIFI
RM0020814 	DESK
RM0020814 	AIR_CONDITION
RM0020815 	WIFI
RM0020815 	DESK
RM0020815 	SAFE
RM0020816 	MICROWAVE
RM0020816 	DESK
RM0020816 	AIR_CONDITION
RM0020816 	FRIDGE
RM0020816 	COFFEE_MAKER
RM0020816 	HAIRDRYER
RM0020816 	IRON
RM0020817 	AIR_CONDITION
RM0020818 	AIR_CONDITION
RM0020900 	WIFI
RM0020900 	DESK
RM0020900 	MINIBAR
RM0020901 	IRON
RM0020901 	WIFI
RM0020901 	DESK
RM0020901 	MINIBAR
RM0020901 	AIR_CONDITION
RM0020901 	SAFE
RM0020901 	HAIRDRYER
RM0020902 	DESK
RM0020902 	IRON
RM0020902 	COFFEE_MAKER
RM0020902 	AIR_CONDITION
RM0020903 	MICROWAVE
RM0020904 	AIR_CONDITION
RM0020904 	MICROWAVE
RM0020904 	COFFEE_MAKER
RM0020904 	SAFE
RM0020904 	HAIRDRYER
RM0020904 	DESK
RM0020905 	TV
RM0020905 	MICROWAVE
RM0020905 	WIFI
RM0020905 	MINIBAR
RM0020905 	COFFEE_MAKER
RM0020905 	DESK
RM0020905 	IRON
RM0020906 	MINIBAR
RM0020906 	FRIDGE
RM0020906 	MICROWAVE
RM0020906 	TV
RM0020906 	IRON
RM0020906 	WIFI
RM0020907 	DESK
RM0020907 	TV
RM0020907 	COFFEE_MAKER
RM0020907 	MICROWAVE
RM0020907 	MINIBAR
RM0020907 	SAFE
RM0020907 	FRIDGE
RM0020907 	AIR_CONDITION
RM0020907 	WIFI
RM0020908 	IRON
RM0020909 	MINIBAR
RM0020909 	AIR_CONDITION
RM0020909 	SAFE
RM0020909 	WIFI
RM0020909 	IRON
RM0020909 	HAIRDRYER
RM0020909 	TV
RM0020909 	MICROWAVE
RM0020909 	COFFEE_MAKER
RM0020909 	FRIDGE
RM0020909 	DESK
RM0020910 	HAIRDRYER
RM0020910 	FRIDGE
RM0020910 	DESK
RM0020911 	COFFEE_MAKER
RM0020911 	SAFE
RM0020911 	IRON
RM0020911 	MICROWAVE
RM0021000 	TV
RM0021000 	WIFI
RM0021000 	DESK
RM0021000 	HAIRDRYER
RM0021000 	IRON
RM0021000 	MICROWAVE
RM0021000 	MINIBAR
RM0021000 	FRIDGE
RM0021000 	SAFE
RM0021000 	AIR_CONDITION
RM0021001 	MINIBAR
RM0021001 	TV
RM0021001 	DESK
RM0021001 	FRIDGE
RM0021002 	HAIRDRYER
RM0021002 	DESK
RM0021002 	WIFI
RM0021002 	IRON
RM0021002 	COFFEE_MAKER
RM0021002 	AIR_CONDITION
RM0021002 	MINIBAR
RM0021002 	FRIDGE
RM0021003 	MICROWAVE
RM0021003 	DESK
RM0021003 	WIFI
RM0021003 	TV
RM0021003 	IRON
RM0021003 	SAFE
RM0021003 	HAIRDRYER
RM0021004 	AIR_CONDITION
RM0021004 	COFFEE_MAKER
RM0021004 	HAIRDRYER
RM0021004 	IRON
RM0021004 	SAFE
RM0021004 	MICROWAVE
RM0021004 	MINIBAR
RM0021005 	HAIRDRYER
RM0021005 	TV
RM0021006 	WIFI
RM0021006 	SAFE
RM0021006 	HAIRDRYER
RM0021006 	MINIBAR
RM0021006 	TV
RM0021006 	AIR_CONDITION
RM0021006 	COFFEE_MAKER
RM0021007 	MICROWAVE
RM0021007 	TV
RM0021007 	SAFE
RM0021008 	TV
RM0021008 	FRIDGE
RM0021008 	AIR_CONDITION
RM0021008 	SAFE
RM0021008 	IRON
RM0021009 	HAIRDRYER
RM0021009 	AIR_CONDITION
RM0021009 	FRIDGE
RM0021009 	DESK
RM0021009 	MICROWAVE
RM0021009 	SAFE
RM0021009 	IRON
RM0021009 	COFFEE_MAKER
RM0021009 	WIFI
RM0021009 	MINIBAR
RM0021010 	SAFE
RM0021011 	IRON
RM0021011 	HAIRDRYER
RM0021011 	WIFI
RM0021011 	SAFE
RM0021011 	MICROWAVE
RM0021011 	TV
RM0021011 	AIR_CONDITION
RM0021012 	MICROWAVE
RM0021012 	MINIBAR
RM0021013 	HAIRDRYER
RM0021013 	MICROWAVE
RM0021100 	DESK
RM0021100 	MICROWAVE
RM0021100 	HAIRDRYER
RM0021100 	IRON
RM0021100 	FRIDGE
RM0021100 	COFFEE_MAKER
RM0021100 	AIR_CONDITION
RM0021100 	WIFI
RM0021100 	TV
RM0021100 	SAFE
RM0021100 	MINIBAR
RM0021101 	FRIDGE
RM0021102 	HAIRDRYER
RM0021102 	COFFEE_MAKER
RM0021102 	TV
RM0021102 	SAFE
RM0021102 	MICROWAVE
RM0021103 	MINIBAR
RM0021103 	FRIDGE
RM0021103 	DESK
RM0021103 	SAFE
RM0021103 	COFFEE_MAKER
RM0021103 	TV
RM0021103 	MICROWAVE
RM0021104 	COFFEE_MAKER
RM0021104 	FRIDGE
RM0021104 	DESK
RM0021104 	TV
RM0021104 	AIR_CONDITION
RM0021104 	WIFI
RM0021104 	IRON
RM0021104 	HAIRDRYER
RM0021104 	SAFE
RM0021104 	MICROWAVE
RM0021104 	MINIBAR
RM0021105 	COFFEE_MAKER
RM0021106 	AIR_CONDITION
RM0021106 	DESK
RM0021106 	IRON
RM0021106 	HAIRDRYER
RM0021106 	WIFI
RM0021106 	SAFE
RM0021107 	FRIDGE
RM0021107 	TV
RM0021107 	SAFE
RM0021107 	DESK
RM0021108 	MICROWAVE
RM0021108 	COFFEE_MAKER
RM0021108 	AIR_CONDITION
RM0021108 	WIFI
RM0021108 	MINIBAR
RM0021108 	TV
RM0021108 	FRIDGE
RM0021108 	HAIRDRYER
RM0021108 	IRON
RM0021108 	SAFE
RM0021108 	DESK
RM0021109 	MINIBAR
RM0021109 	MICROWAVE
RM0021109 	IRON
RM0021109 	DESK
RM0021109 	HAIRDRYER
RM0021109 	COFFEE_MAKER
RM0021109 	FRIDGE
RM0021110 	MINIBAR
RM0021111 	HAIRDRYER
RM0021111 	WIFI
RM0021111 	IRON
RM0021111 	COFFEE_MAKER
RM0021111 	MINIBAR
RM0021111 	MICROWAVE
RM0021111 	TV
RM0021111 	FRIDGE
RM0021111 	DESK
RM0021111 	SAFE
RM0021112 	HAIRDRYER
RM0021112 	SAFE
RM0021112 	MINIBAR
RM0021112 	COFFEE_MAKER
RM0021112 	WIFI
RM0021112 	DESK
RM0021112 	MICROWAVE
RM0021112 	FRIDGE
RM0021112 	TV
RM0021112 	AIR_CONDITION
RM0021112 	IRON
RM0021113 	WIFI
RM0021113 	MINIBAR
RM0021113 	SAFE
RM0021114 	HAIRDRYER
RM0021114 	SAFE
RM0021114 	AIR_CONDITION
RM0021114 	MINIBAR
RM0021114 	TV
RM0021114 	FRIDGE
RM0021114 	IRON
RM0021114 	WIFI
RM0021114 	MICROWAVE
RM0021114 	DESK
RM0021115 	SAFE
RM0021115 	IRON
RM0021115 	TV
RM0021115 	MINIBAR
RM0021116 	IRON
RM0021116 	MICROWAVE
RM0021117 	AIR_CONDITION
RM0021117 	HAIRDRYER
RM0021117 	COFFEE_MAKER
RM0021118 	SAFE
RM0021118 	HAIRDRYER
RM0021118 	FRIDGE
RM0021118 	DESK
RM0021118 	MINIBAR
RM0021118 	TV
RM0021118 	WIFI
RM0021118 	COFFEE_MAKER
RM0021118 	MICROWAVE
RM0021118 	IRON
RM0021118 	AIR_CONDITION
RM0021200 	COFFEE_MAKER
RM0021200 	WIFI
RM0021200 	AIR_CONDITION
RM0021200 	SAFE
RM0021200 	TV
RM0021200 	MICROWAVE
RM0021200 	MINIBAR
RM0021200 	IRON
RM0021200 	DESK
RM0021200 	FRIDGE
RM0021201 	COFFEE_MAKER
RM0021201 	MINIBAR
RM0021201 	IRON
RM0021202 	DESK
RM0021202 	MICROWAVE
RM0021202 	HAIRDRYER
RM0021203 	SAFE
RM0021203 	COFFEE_MAKER
RM0021203 	MINIBAR
RM0021203 	DESK
RM0021203 	FRIDGE
RM0021203 	AIR_CONDITION
RM0021204 	MINIBAR
RM0021204 	WIFI
RM0021204 	DESK
RM0021204 	TV
RM0021204 	HAIRDRYER
RM0021204 	FRIDGE
RM0021204 	MICROWAVE
RM0021205 	SAFE
RM0021205 	MINIBAR
RM0021205 	MICROWAVE
RM0021205 	FRIDGE
RM0021205 	WIFI
RM0021205 	AIR_CONDITION
RM0021205 	IRON
RM0021205 	DESK
RM0021206 	MINIBAR
RM0021206 	FRIDGE
RM0021206 	AIR_CONDITION
RM0021206 	MICROWAVE
RM0021206 	SAFE
RM0021206 	DESK
RM0021206 	HAIRDRYER
RM0021206 	IRON
RM0021207 	MICROWAVE
RM0021207 	MINIBAR
RM0021207 	IRON
RM0021207 	FRIDGE
RM0021207 	COFFEE_MAKER
RM0021207 	HAIRDRYER
RM0021207 	AIR_CONDITION
RM0021208 	MINIBAR
RM0021208 	WIFI
RM0021208 	TV
RM0021208 	IRON
RM0021208 	FRIDGE
RM0021208 	SAFE
RM0021208 	HAIRDRYER
RM0021208 	DESK
RM0021209 	MINIBAR
RM0021209 	IRON
RM0021209 	AIR_CONDITION
RM0021209 	WIFI
RM0021209 	DESK
RM0021210 	MINIBAR
RM0021210 	MICROWAVE
RM0021210 	FRIDGE
RM0021210 	IRON
RM0021210 	AIR_CONDITION
RM0021210 	HAIRDRYER
RM0021210 	WIFI
RM0021210 	DESK
RM0021210 	TV
RM0021210 	COFFEE_MAKER
RM0021211 	DESK
RM0021212 	COFFEE_MAKER
RM0021212 	FRIDGE
RM0021213 	TV
RM0021213 	MICROWAVE
RM0021213 	WIFI
RM0021213 	MINIBAR
RM0021213 	HAIRDRYER
RM0021213 	SAFE
RM0021214 	HAIRDRYER
RM0021214 	DESK
RM0021214 	MICROWAVE
RM0021214 	AIR_CONDITION
RM0021214 	MINIBAR
RM0021214 	COFFEE_MAKER
RM0021215 	MICROWAVE
RM0021215 	FRIDGE
RM0021216 	SAFE
RM0021216 	FRIDGE
RM0021216 	MINIBAR
RM0021216 	TV
RM0021216 	DESK
RM0021217 	MINIBAR
RM0021217 	IRON
RM0021217 	HAIRDRYER
RM0021217 	MICROWAVE
RM0021300 	AIR_CONDITION
RM0021300 	TV
RM0021300 	MINIBAR
RM0021300 	MICROWAVE
RM0021300 	WIFI
RM0021300 	DESK
RM0021300 	HAIRDRYER
RM0021300 	SAFE
RM0021301 	COFFEE_MAKER
RM0021301 	MICROWAVE
RM0021301 	FRIDGE
RM0021301 	DESK
RM0021301 	HAIRDRYER
RM0021301 	WIFI
RM0021301 	AIR_CONDITION
RM0021301 	MINIBAR
RM0021301 	IRON
RM0021301 	SAFE
RM0021301 	TV
RM0021302 	DESK
RM0021302 	SAFE
RM0021302 	WIFI
RM0021302 	MINIBAR
RM0021302 	IRON
RM0021302 	FRIDGE
RM0021302 	HAIRDRYER
RM0021302 	TV
RM0021303 	WIFI
RM0021303 	FRIDGE
RM0021303 	MINIBAR
RM0021303 	COFFEE_MAKER
RM0021303 	AIR_CONDITION
RM0021303 	DESK
RM0021304 	FRIDGE
RM0021304 	HAIRDRYER
RM0021304 	IRON
RM0021304 	SAFE
RM0021304 	WIFI
RM0021304 	COFFEE_MAKER
RM0021305 	DESK
RM0021305 	TV
RM0021306 	MINIBAR
RM0021306 	HAIRDRYER
RM0021306 	DESK
RM0021307 	COFFEE_MAKER
RM0021307 	WIFI
RM0021307 	SAFE
RM0021307 	DESK
RM0021307 	MINIBAR
RM0021307 	FRIDGE
RM0021308 	MINIBAR
RM0021308 	AIR_CONDITION
RM0021308 	SAFE
RM0021308 	WIFI
RM0021309 	MINIBAR
RM0021309 	TV
RM0021309 	DESK
RM0021309 	MICROWAVE
RM0021309 	SAFE
RM0021309 	WIFI
RM0021400 	TV
RM0021400 	MINIBAR
RM0021400 	HAIRDRYER
RM0021400 	MICROWAVE
RM0021400 	SAFE
RM0021400 	FRIDGE
RM0021400 	COFFEE_MAKER
RM0021400 	IRON
RM0021400 	AIR_CONDITION
RM0021400 	WIFI
RM0021400 	DESK
RM0021401 	HAIRDRYER
RM0021401 	MINIBAR
RM0021401 	MICROWAVE
RM0021401 	FRIDGE
RM0021401 	WIFI
RM0021402 	HAIRDRYER
RM0021402 	TV
RM0021402 	IRON
RM0021402 	WIFI
RM0021403 	COFFEE_MAKER
RM0021404 	SAFE
RM0021404 	FRIDGE
RM0021405 	HAIRDRYER
RM0021405 	SAFE
RM0021405 	TV
RM0021405 	MINIBAR
RM0021405 	MICROWAVE
RM0021406 	FRIDGE
RM0021406 	SAFE
RM0021406 	HAIRDRYER
RM0021407 	MICROWAVE
RM0021407 	MINIBAR
RM0021407 	DESK
RM0021407 	SAFE
RM0021407 	HAIRDRYER
RM0021407 	COFFEE_MAKER
RM0021407 	IRON
RM0021407 	FRIDGE
RM0021407 	TV
RM0021408 	IRON
RM0021408 	AIR_CONDITION
RM0021408 	MINIBAR
RM0021408 	DESK
RM0021408 	MICROWAVE
RM0021409 	COFFEE_MAKER
RM0021409 	SAFE
RM0021410 	FRIDGE
RM0021410 	WIFI
RM0021410 	HAIRDRYER
RM0021410 	MINIBAR
RM0021411 	IRON
RM0021411 	AIR_CONDITION
RM0021411 	FRIDGE
RM0021411 	HAIRDRYER
RM0021411 	MICROWAVE
RM0021411 	TV
RM0021500 	TV
RM0021500 	HAIRDRYER
RM0021500 	AIR_CONDITION
RM0021500 	SAFE
RM0021500 	DESK
RM0021500 	MINIBAR
RM0021500 	MICROWAVE
RM0021500 	FRIDGE
RM0021501 	WIFI
RM0021501 	FRIDGE
RM0021501 	AIR_CONDITION
RM0021501 	MINIBAR
RM0021501 	DESK
RM0021501 	SAFE
RM0021501 	COFFEE_MAKER
RM0021501 	IRON
RM0021501 	HAIRDRYER
RM0021502 	AIR_CONDITION
RM0021502 	WIFI
RM0021502 	HAIRDRYER
RM0021502 	COFFEE_MAKER
RM0021502 	FRIDGE
RM0021502 	IRON
RM0021502 	MICROWAVE
RM0021502 	SAFE
RM0021502 	TV
RM0021502 	DESK
RM0021502 	MINIBAR
RM0021503 	TV
RM0021503 	COFFEE_MAKER
RM0021503 	MINIBAR
RM0021503 	AIR_CONDITION
RM0021503 	MICROWAVE
RM0021503 	HAIRDRYER
RM0021503 	IRON
RM0021503 	FRIDGE
RM0021504 	TV
RM0021504 	DESK
RM0021504 	IRON
RM0021504 	MICROWAVE
RM0021505 	FRIDGE
RM0021505 	SAFE
RM0021505 	HAIRDRYER
RM0021506 	WIFI
RM0021506 	FRIDGE
RM0021507 	TV
RM0021507 	MICROWAVE
RM0021507 	COFFEE_MAKER
RM0021508 	IRON
RM0021508 	TV
RM0021508 	DESK
RM0021508 	MINIBAR
RM0021508 	MICROWAVE
RM0021508 	SAFE
RM0021509 	MICROWAVE
RM0021509 	SAFE
RM0021509 	COFFEE_MAKER
RM0021509 	HAIRDRYER
RM0021509 	WIFI
RM0021509 	FRIDGE
RM0021509 	AIR_CONDITION
RM0021509 	IRON
RM0021510 	IRON
RM0021510 	WIFI
RM0021511 	DESK
RM0021511 	HAIRDRYER
RM0021511 	IRON
RM0021511 	MICROWAVE
RM0021511 	WIFI
RM0021512 	MINIBAR
RM0021512 	WIFI
RM0021512 	TV
RM0021512 	FRIDGE
RM0021512 	DESK
RM0021600 	IRON
RM0021600 	FRIDGE
RM0021601 	TV
RM0021601 	COFFEE_MAKER
RM0021601 	DESK
RM0021601 	HAIRDRYER
RM0021601 	WIFI
RM0021602 	DESK
RM0021603 	MINIBAR
RM0021603 	WIFI
RM0021604 	MINIBAR
RM0021604 	MICROWAVE
RM0021604 	DESK
RM0021604 	COFFEE_MAKER
RM0021604 	SAFE
RM0021604 	HAIRDRYER
RM0021604 	IRON
RM0021604 	WIFI
RM0021605 	MICROWAVE
RM0021605 	WIFI
RM0021605 	FRIDGE
RM0021605 	SAFE
RM0021605 	COFFEE_MAKER
RM0021605 	AIR_CONDITION
RM0021605 	TV
RM0021605 	DESK
RM0021606 	SAFE
RM0021606 	DESK
RM0021607 	MINIBAR
RM0021607 	DESK
RM0021607 	AIR_CONDITION
RM0021607 	MICROWAVE
RM0021607 	SAFE
RM0021608 	TV
RM0021608 	MINIBAR
RM0021608 	COFFEE_MAKER
RM0021608 	SAFE
RM0021608 	WIFI
RM0021608 	HAIRDRYER
RM0021608 	FRIDGE
RM0021608 	DESK
RM0021609 	FRIDGE
RM0021609 	AIR_CONDITION
RM0021609 	DESK
RM0021609 	TV
RM0021609 	COFFEE_MAKER
RM0021609 	MINIBAR
RM0021609 	SAFE
RM0021609 	IRON
RM0021609 	MICROWAVE
RM0021609 	HAIRDRYER
RM0021610 	COFFEE_MAKER
RM0021610 	SAFE
RM0021610 	AIR_CONDITION
RM0021610 	DESK
RM0021610 	HAIRDRYER
RM0021610 	WIFI
RM0021610 	TV
RM0021610 	MICROWAVE
RM0021610 	FRIDGE
RM0021611 	TV
RM0021611 	MICROWAVE
RM0021611 	HAIRDRYER
RM0021611 	DESK
RM0021611 	AIR_CONDITION
RM0021611 	IRON
RM0021612 	DESK
RM0021612 	MICROWAVE
RM0021612 	TV
RM0021612 	COFFEE_MAKER
RM0021612 	IRON
RM0021612 	SAFE
RM0021612 	MINIBAR
RM0021612 	WIFI
RM0021700 	TV
RM0021700 	AIR_CONDITION
RM0021701 	HAIRDRYER
RM0021701 	FRIDGE
RM0021701 	IRON
RM0021702 	COFFEE_MAKER
RM0021702 	DESK
RM0021702 	IRON
RM0021702 	AIR_CONDITION
RM0021702 	MICROWAVE
RM0021702 	HAIRDRYER
RM0021702 	SAFE
RM0021702 	TV
RM0021702 	MINIBAR
RM0021702 	WIFI
RM0021703 	FRIDGE
RM0021703 	MINIBAR
RM0021703 	HAIRDRYER
RM0021703 	SAFE
RM0021703 	DESK
RM0021703 	WIFI
RM0021703 	IRON
RM0021703 	COFFEE_MAKER
RM0021703 	TV
RM0021703 	MICROWAVE
RM0021704 	COFFEE_MAKER
RM0021705 	IRON
RM0021705 	MICROWAVE
RM0021705 	AIR_CONDITION
RM0021705 	COFFEE_MAKER
RM0021705 	SAFE
RM0021705 	HAIRDRYER
RM0021705 	TV
RM0021706 	IRON
RM0021706 	WIFI
RM0021706 	TV
RM0021706 	MICROWAVE
RM0021706 	DESK
RM0021706 	HAIRDRYER
RM0021706 	FRIDGE
RM0021706 	COFFEE_MAKER
RM0021706 	AIR_CONDITION
RM0021706 	MINIBAR
RM0021707 	MINIBAR
RM0021708 	MICROWAVE
RM0021708 	DESK
RM0021708 	COFFEE_MAKER
RM0021709 	MINIBAR
RM0021709 	MICROWAVE
RM0021709 	DESK
RM0021709 	FRIDGE
RM0021709 	HAIRDRYER
RM0021709 	COFFEE_MAKER
RM0021709 	TV
RM0021710 	DESK
RM0021710 	COFFEE_MAKER
RM0021710 	IRON
RM0021710 	FRIDGE
RM0021710 	TV
RM0021711 	SAFE
RM0021712 	HAIRDRYER
RM0021712 	COFFEE_MAKER
RM0021712 	MICROWAVE
RM0021712 	MINIBAR
RM0021712 	DESK
RM0021712 	SAFE
RM0021712 	TV
RM0021712 	FRIDGE
RM0021712 	IRON
RM0021712 	WIFI
RM0021713 	FRIDGE
RM0021713 	HAIRDRYER
RM0021713 	SAFE
RM0021713 	TV
RM0021713 	WIFI
RM0021713 	IRON
RM0030000 	MINIBAR
RM0030000 	AIR_CONDITION
RM0030000 	IRON
RM0030000 	SAFE
RM0030001 	MINIBAR
RM0030001 	WIFI
RM0030001 	TV
RM0030001 	MICROWAVE
RM0030001 	DESK
RM0030002 	IRON
RM0030002 	DESK
RM0030002 	FRIDGE
RM0030003 	AIR_CONDITION
RM0030003 	COFFEE_MAKER
RM0030003 	MICROWAVE
RM0030003 	IRON
RM0030003 	DESK
RM0030003 	WIFI
RM0030003 	SAFE
RM0030003 	TV
RM0030004 	WIFI
RM0030004 	FRIDGE
RM0030004 	MINIBAR
RM0030004 	MICROWAVE
RM0030004 	AIR_CONDITION
RM0030005 	MINIBAR
RM0030005 	WIFI
RM0030005 	AIR_CONDITION
RM0030005 	HAIRDRYER
RM0030005 	DESK
RM0030006 	DESK
RM0030006 	HAIRDRYER
RM0030006 	TV
RM0030006 	COFFEE_MAKER
RM0030006 	SAFE
RM0030006 	WIFI
RM0030006 	AIR_CONDITION
RM0030006 	IRON
RM0030006 	MINIBAR
RM0030006 	FRIDGE
RM0030006 	MICROWAVE
RM0030007 	TV
RM0030007 	IRON
RM0030007 	MINIBAR
RM0030007 	WIFI
RM0030007 	HAIRDRYER
RM0030007 	FRIDGE
RM0030007 	COFFEE_MAKER
RM0030007 	MICROWAVE
RM0030007 	DESK
RM0030008 	TV
RM0030008 	IRON
RM0030008 	MINIBAR
RM0030008 	HAIRDRYER
RM0030009 	FRIDGE
RM0030009 	COFFEE_MAKER
RM0030009 	MICROWAVE
RM0030009 	IRON
RM0030009 	DESK
RM0030009 	MINIBAR
RM0030009 	HAIRDRYER
RM0030010 	AIR_CONDITION
RM0030010 	SAFE
RM0030010 	IRON
RM0030010 	MICROWAVE
RM0030010 	MINIBAR
RM0030010 	COFFEE_MAKER
RM0030010 	DESK
RM0030010 	WIFI
RM0030010 	HAIRDRYER
RM0030010 	FRIDGE
RM0030010 	TV
RM0030011 	SAFE
RM0030011 	MICROWAVE
RM0030012 	IRON
RM0030012 	COFFEE_MAKER
RM0030012 	AIR_CONDITION
RM0030012 	DESK
RM0030013 	TV
RM0030013 	SAFE
RM0030013 	HAIRDRYER
RM0030013 	AIR_CONDITION
RM0030013 	MICROWAVE
RM0030013 	IRON
RM0030013 	COFFEE_MAKER
RM0030013 	FRIDGE
RM0030013 	DESK
RM0030014 	MINIBAR
RM0030014 	COFFEE_MAKER
RM0030014 	SAFE
RM0030014 	MICROWAVE
RM0030014 	HAIRDRYER
RM0030014 	WIFI
RM0030014 	IRON
RM0030014 	AIR_CONDITION
RM0030015 	HAIRDRYER
RM0030015 	TV
RM0030015 	SAFE
RM0030015 	FRIDGE
RM0030015 	IRON
RM0030015 	MICROWAVE
RM0030016 	HAIRDRYER
RM0030016 	DESK
RM0030016 	MINIBAR
RM0030016 	FRIDGE
RM0030017 	FRIDGE
RM0030017 	MICROWAVE
RM0030100 	AIR_CONDITION
RM0030100 	DESK
RM0030100 	FRIDGE
RM0030100 	TV
RM0030100 	WIFI
RM0030100 	COFFEE_MAKER
RM0030100 	IRON
RM0030100 	SAFE
RM0030100 	MINIBAR
RM0030100 	HAIRDRYER
RM0030101 	FRIDGE
RM0030101 	SAFE
RM0030101 	MINIBAR
RM0030101 	MICROWAVE
RM0030101 	HAIRDRYER
RM0030101 	WIFI
RM0030101 	IRON
RM0030101 	TV
RM0030101 	COFFEE_MAKER
RM0030101 	DESK
RM0030101 	AIR_CONDITION
RM0030102 	WIFI
RM0030102 	COFFEE_MAKER
RM0030102 	FRIDGE
RM0030102 	MICROWAVE
RM0030102 	HAIRDRYER
RM0030102 	IRON
RM0030102 	DESK
RM0030102 	TV
RM0030102 	MINIBAR
RM0030102 	AIR_CONDITION
RM0030103 	TV
RM0030103 	AIR_CONDITION
RM0030103 	DESK
RM0030104 	WIFI
RM0030104 	TV
RM0030104 	FRIDGE
RM0030104 	SAFE
RM0030104 	MINIBAR
RM0030104 	HAIRDRYER
RM0030104 	IRON
RM0030105 	AIR_CONDITION
RM0030106 	SAFE
RM0030106 	TV
RM0030106 	WIFI
RM0030106 	DESK
RM0030106 	MINIBAR
RM0030106 	MICROWAVE
RM0030106 	COFFEE_MAKER
RM0030107 	DESK
RM0030107 	WIFI
RM0030107 	AIR_CONDITION
RM0030107 	HAIRDRYER
RM0030107 	TV
RM0030107 	MINIBAR
RM0030107 	COFFEE_MAKER
RM0030107 	SAFE
RM0030107 	FRIDGE
RM0030107 	MICROWAVE
RM0030107 	IRON
RM0030108 	IRON
RM0030108 	COFFEE_MAKER
RM0030109 	COFFEE_MAKER
RM0030109 	MICROWAVE
RM0030109 	AIR_CONDITION
RM0030109 	TV
RM0030109 	DESK
RM0030109 	MINIBAR
RM0030109 	HAIRDRYER
RM0030109 	IRON
RM0030109 	WIFI
RM0030109 	SAFE
RM0030109 	FRIDGE
RM0030110 	COFFEE_MAKER
RM0030110 	FRIDGE
RM0030110 	AIR_CONDITION
RM0030110 	MICROWAVE
RM0030110 	TV
RM0030110 	SAFE
RM0030111 	MICROWAVE
RM0030111 	SAFE
RM0030111 	FRIDGE
RM0030111 	TV
RM0030111 	HAIRDRYER
RM0030111 	IRON
RM0030112 	IRON
RM0030112 	FRIDGE
RM0030112 	DESK
RM0030112 	MICROWAVE
RM0030112 	HAIRDRYER
RM0030112 	SAFE
RM0030112 	MINIBAR
RM0030112 	AIR_CONDITION
RM0030113 	SAFE
RM0030113 	IRON
RM0030113 	WIFI
RM0030113 	TV
RM0030113 	MINIBAR
RM0030113 	HAIRDRYER
RM0030114 	MINIBAR
RM0030114 	FRIDGE
RM0030114 	SAFE
RM0030114 	MICROWAVE
RM0030114 	COFFEE_MAKER
RM0030114 	DESK
RM0030115 	MINIBAR
RM0030115 	MICROWAVE
RM0030115 	TV
RM0030200 	FRIDGE
RM0030200 	TV
RM0030200 	COFFEE_MAKER
RM0030200 	IRON
RM0030200 	AIR_CONDITION
RM0030200 	HAIRDRYER
RM0030200 	SAFE
RM0030201 	FRIDGE
RM0030201 	WIFI
RM0030201 	HAIRDRYER
RM0030201 	AIR_CONDITION
RM0030201 	MINIBAR
RM0030201 	IRON
RM0030201 	TV
RM0030201 	DESK
RM0030201 	MICROWAVE
RM0030202 	FRIDGE
RM0030202 	MINIBAR
RM0030202 	AIR_CONDITION
RM0030202 	HAIRDRYER
RM0030202 	COFFEE_MAKER
RM0030202 	DESK
RM0030202 	IRON
RM0030202 	MICROWAVE
RM0030202 	SAFE
RM0030202 	TV
RM0030203 	IRON
RM0030203 	COFFEE_MAKER
RM0030203 	SAFE
RM0030204 	SAFE
RM0030204 	IRON
RM0030204 	COFFEE_MAKER
RM0030204 	HAIRDRYER
RM0030204 	MINIBAR
RM0030204 	WIFI
RM0030205 	FRIDGE
RM0030205 	WIFI
RM0030206 	AIR_CONDITION
RM0030206 	SAFE
RM0030206 	COFFEE_MAKER
RM0030206 	DESK
RM0030206 	FRIDGE
RM0030206 	HAIRDRYER
RM0030206 	IRON
RM0030206 	TV
RM0030206 	MINIBAR
RM0030206 	MICROWAVE
RM0030207 	SAFE
RM0030207 	MINIBAR
RM0030207 	WIFI
RM0030207 	COFFEE_MAKER
RM0030207 	MICROWAVE
RM0030207 	IRON
RM0030207 	DESK
RM0030207 	TV
RM0030207 	FRIDGE
RM0030207 	AIR_CONDITION
RM0030207 	HAIRDRYER
RM0030208 	AIR_CONDITION
RM0030208 	SAFE
RM0030208 	WIFI
RM0030208 	MICROWAVE
RM0030208 	DESK
RM0030208 	MINIBAR
RM0030208 	HAIRDRYER
RM0030209 	COFFEE_MAKER
RM0030209 	SAFE
RM0030209 	HAIRDRYER
RM0030209 	MINIBAR
RM0030209 	TV
RM0030210 	FRIDGE
RM0030210 	TV
RM0030210 	DESK
RM0030210 	AIR_CONDITION
RM0030300 	FRIDGE
RM0030300 	SAFE
RM0030300 	HAIRDRYER
RM0030301 	FRIDGE
RM0030301 	MICROWAVE
RM0030301 	IRON
RM0030301 	WIFI
RM0030301 	HAIRDRYER
RM0030301 	DESK
RM0030302 	AIR_CONDITION
RM0030302 	COFFEE_MAKER
RM0030302 	MICROWAVE
RM0030302 	MINIBAR
RM0030302 	IRON
RM0030302 	WIFI
RM0030303 	WIFI
RM0030303 	HAIRDRYER
RM0030303 	DESK
RM0030303 	MICROWAVE
RM0030303 	AIR_CONDITION
RM0030303 	MINIBAR
RM0030303 	TV
RM0030303 	COFFEE_MAKER
RM0030303 	IRON
RM0030304 	DESK
RM0030304 	SAFE
RM0030304 	MICROWAVE
RM0030305 	AIR_CONDITION
RM0030305 	MINIBAR
RM0030306 	AIR_CONDITION
RM0030306 	IRON
RM0030306 	MINIBAR
RM0030306 	FRIDGE
RM0030306 	HAIRDRYER
RM0030306 	COFFEE_MAKER
RM0030306 	DESK
RM0030307 	TV
RM0030307 	MINIBAR
RM0030307 	COFFEE_MAKER
RM0030308 	SAFE
RM0030308 	MICROWAVE
RM0030309 	TV
RM0030309 	FRIDGE
RM0030309 	MICROWAVE
RM0030309 	AIR_CONDITION
RM0030309 	HAIRDRYER
RM0030309 	WIFI
RM0030309 	IRON
RM0030309 	DESK
RM0030310 	TV
RM0030310 	IRON
RM0030310 	MICROWAVE
RM0030310 	AIR_CONDITION
RM0030310 	MINIBAR
RM0030311 	AIR_CONDITION
RM0030311 	MICROWAVE
RM0030311 	WIFI
RM0030311 	MINIBAR
RM0030311 	TV
RM0030311 	DESK
RM0030312 	SAFE
RM0030312 	DESK
RM0030312 	COFFEE_MAKER
RM0030312 	TV
RM0030312 	WIFI
RM0030313 	WIFI
RM0030313 	TV
RM0030313 	SAFE
RM0030313 	FRIDGE
RM0030313 	HAIRDRYER
RM0030313 	IRON
RM0030313 	MINIBAR
RM0030313 	COFFEE_MAKER
RM0030313 	MICROWAVE
RM0030400 	TV
RM0030400 	COFFEE_MAKER
RM0030400 	HAIRDRYER
RM0030400 	IRON
RM0030400 	WIFI
RM0030400 	AIR_CONDITION
RM0030400 	DESK
RM0030400 	MICROWAVE
RM0030400 	FRIDGE
RM0030401 	FRIDGE
RM0030402 	TV
RM0030402 	DESK
RM0030402 	HAIRDRYER
RM0030402 	AIR_CONDITION
RM0030403 	SAFE
RM0030403 	HAIRDRYER
RM0030403 	WIFI
RM0030403 	COFFEE_MAKER
RM0030403 	DESK
RM0030403 	MICROWAVE
RM0030403 	AIR_CONDITION
RM0030403 	IRON
RM0030403 	MINIBAR
RM0030403 	TV
RM0030404 	FRIDGE
RM0030404 	MICROWAVE
RM0030404 	AIR_CONDITION
RM0030404 	DESK
RM0030404 	HAIRDRYER
RM0030404 	TV
RM0030404 	SAFE
RM0030404 	IRON
RM0030404 	WIFI
RM0030405 	FRIDGE
RM0030405 	MICROWAVE
RM0030405 	SAFE
RM0030405 	MINIBAR
RM0030405 	HAIRDRYER
RM0030405 	COFFEE_MAKER
RM0030406 	IRON
RM0030406 	MICROWAVE
RM0030406 	MINIBAR
RM0030406 	DESK
RM0030407 	FRIDGE
RM0030407 	SAFE
RM0030407 	COFFEE_MAKER
RM0030407 	AIR_CONDITION
RM0030407 	MINIBAR
RM0030407 	MICROWAVE
RM0030407 	DESK
RM0030407 	TV
RM0030407 	IRON
RM0030407 	WIFI
RM0030407 	HAIRDRYER
RM0030408 	WIFI
RM0030408 	MICROWAVE
RM0030408 	TV
RM0030408 	SAFE
RM0030409 	MINIBAR
RM0030409 	TV
RM0030409 	AIR_CONDITION
RM0030409 	COFFEE_MAKER
RM0030410 	COFFEE_MAKER
RM0030410 	MICROWAVE
RM0030410 	AIR_CONDITION
RM0030410 	MINIBAR
RM0030410 	SAFE
RM0030410 	IRON
RM0030410 	TV
RM0030410 	HAIRDRYER
RM0030410 	WIFI
RM0030410 	DESK
RM0030411 	COFFEE_MAKER
RM0030411 	FRIDGE
RM0030411 	DESK
RM0030411 	WIFI
RM0030411 	TV
RM0030411 	IRON
RM0030411 	MICROWAVE
RM0030412 	DESK
RM0030412 	COFFEE_MAKER
RM0030412 	HAIRDRYER
RM0030412 	WIFI
RM0030412 	MINIBAR
RM0030412 	TV
RM0030412 	MICROWAVE
RM0030412 	AIR_CONDITION
RM0030413 	FRIDGE
RM0030413 	AIR_CONDITION
RM0030413 	SAFE
RM0030413 	HAIRDRYER
RM0030500 	DESK
RM0030500 	MINIBAR
RM0030500 	FRIDGE
RM0030500 	WIFI
RM0030500 	HAIRDRYER
RM0030500 	COFFEE_MAKER
RM0030500 	TV
RM0030501 	SAFE
RM0030501 	IRON
RM0030501 	DESK
RM0030502 	TV
RM0030503 	MINIBAR
RM0030503 	COFFEE_MAKER
RM0030503 	SAFE
RM0030503 	AIR_CONDITION
RM0030503 	FRIDGE
RM0030503 	WIFI
RM0030503 	TV
RM0030504 	MINIBAR
RM0030504 	TV
RM0030504 	WIFI
RM0030504 	SAFE
RM0030504 	AIR_CONDITION
RM0030504 	DESK
RM0030504 	COFFEE_MAKER
RM0030504 	FRIDGE
RM0030504 	IRON
RM0030504 	HAIRDRYER
RM0030505 	HAIRDRYER
RM0030505 	MICROWAVE
RM0030505 	WIFI
RM0030505 	IRON
RM0030505 	TV
RM0030505 	AIR_CONDITION
RM0030505 	SAFE
RM0030505 	DESK
RM0030505 	COFFEE_MAKER
RM0030506 	HAIRDRYER
RM0030507 	SAFE
RM0030508 	FRIDGE
RM0030508 	WIFI
RM0030509 	MINIBAR
RM0030509 	DESK
RM0030509 	COFFEE_MAKER
RM0030509 	TV
RM0030510 	HAIRDRYER
RM0030510 	MICROWAVE
RM0030510 	FRIDGE
RM0030510 	IRON
RM0030510 	AIR_CONDITION
RM0030510 	SAFE
RM0030510 	MINIBAR
RM0030510 	WIFI
RM0030510 	DESK
RM0030510 	COFFEE_MAKER
RM0030511 	FRIDGE
RM0030511 	MICROWAVE
RM0030511 	COFFEE_MAKER
RM0030511 	IRON
RM0030511 	SAFE
RM0030511 	HAIRDRYER
RM0030512 	FRIDGE
RM0030512 	IRON
RM0030513 	FRIDGE
RM0030513 	HAIRDRYER
RM0030513 	COFFEE_MAKER
RM0030513 	DESK
RM0030600 	WIFI
RM0030600 	SAFE
RM0030600 	HAIRDRYER
RM0030600 	IRON
RM0030601 	WIFI
RM0030601 	SAFE
RM0030601 	MINIBAR
RM0030602 	IRON
RM0030602 	SAFE
RM0030602 	MINIBAR
RM0030602 	WIFI
RM0030602 	MICROWAVE
RM0030602 	COFFEE_MAKER
RM0030603 	HAIRDRYER
RM0030603 	FRIDGE
RM0030604 	DESK
RM0030604 	SAFE
RM0030605 	WIFI
RM0030605 	TV
RM0030605 	DESK
RM0030605 	MINIBAR
RM0030605 	COFFEE_MAKER
RM0030605 	SAFE
RM0030605 	MICROWAVE
RM0030605 	FRIDGE
RM0030606 	WIFI
RM0030606 	TV
RM0030606 	COFFEE_MAKER
RM0030606 	HAIRDRYER
RM0030606 	AIR_CONDITION
RM0030606 	MINIBAR
RM0030606 	SAFE
RM0030606 	FRIDGE
RM0030606 	DESK
RM0030606 	IRON
RM0030607 	MICROWAVE
RM0030607 	AIR_CONDITION
RM0030607 	IRON
RM0030607 	MINIBAR
RM0030607 	DESK
RM0030607 	COFFEE_MAKER
RM0030607 	TV
RM0030607 	SAFE
RM0030607 	WIFI
RM0030607 	HAIRDRYER
RM0030607 	FRIDGE
RM0030608 	FRIDGE
RM0030608 	TV
RM0030608 	AIR_CONDITION
RM0030608 	COFFEE_MAKER
RM0030608 	IRON
RM0030608 	WIFI
RM0030609 	FRIDGE
RM0030609 	IRON
RM0030609 	TV
RM0030609 	HAIRDRYER
RM0030609 	WIFI
RM0030609 	DESK
RM0030610 	WIFI
RM0030610 	DESK
RM0030610 	IRON
RM0030700 	FRIDGE
RM0030700 	IRON
RM0030700 	HAIRDRYER
RM0030700 	DESK
RM0030700 	MICROWAVE
RM0030700 	TV
RM0030700 	COFFEE_MAKER
RM0030701 	COFFEE_MAKER
RM0030701 	WIFI
RM0030701 	MINIBAR
RM0030701 	TV
RM0030701 	HAIRDRYER
RM0030701 	SAFE
RM0030701 	FRIDGE
RM0030701 	DESK
RM0030702 	MICROWAVE
RM0030702 	DESK
RM0030702 	TV
RM0030702 	HAIRDRYER
RM0030702 	IRON
RM0030702 	MINIBAR
RM0030702 	COFFEE_MAKER
RM0030702 	WIFI
RM0030702 	FRIDGE
RM0030702 	AIR_CONDITION
RM0030703 	IRON
RM0030703 	MICROWAVE
RM0030703 	DESK
RM0030703 	SAFE
RM0030703 	TV
RM0030703 	WIFI
RM0030703 	FRIDGE
RM0030703 	COFFEE_MAKER
RM0030704 	AIR_CONDITION
RM0030704 	DESK
RM0030704 	MINIBAR
RM0030704 	TV
RM0030704 	IRON
RM0030704 	MICROWAVE
RM0030704 	WIFI
RM0030704 	HAIRDRYER
RM0030704 	FRIDGE
RM0030704 	SAFE
RM0030704 	COFFEE_MAKER
RM0030705 	MINIBAR
RM0030706 	MINIBAR
RM0030706 	FRIDGE
RM0030706 	AIR_CONDITION
RM0030706 	MICROWAVE
RM0030706 	SAFE
RM0030706 	TV
RM0030707 	WIFI
RM0030707 	AIR_CONDITION
RM0030707 	DESK
RM0030707 	SAFE
RM0030707 	TV
RM0030708 	FRIDGE
RM0030708 	MICROWAVE
RM0030708 	HAIRDRYER
RM0030709 	WIFI
RM0030709 	AIR_CONDITION
RM0030709 	MINIBAR
RM0030710 	HAIRDRYER
RM0030710 	TV
RM0030710 	AIR_CONDITION
RM0030711 	WIFI
RM0030711 	AIR_CONDITION
RM0030711 	FRIDGE
RM0030711 	COFFEE_MAKER
RM0030711 	SAFE
RM0030711 	HAIRDRYER
RM0030711 	MICROWAVE
RM0030711 	MINIBAR
RM0030712 	SAFE
RM0030712 	HAIRDRYER
RM0030712 	DESK
RM0030712 	MICROWAVE
RM0030712 	IRON
RM0030712 	FRIDGE
RM0030712 	WIFI
RM0030712 	MINIBAR
RM0030713 	WIFI
RM0030713 	DESK
RM0030713 	FRIDGE
RM0030713 	IRON
RM0030714 	WIFI
RM0030714 	SAFE
RM0030714 	HAIRDRYER
RM0030714 	COFFEE_MAKER
RM0030715 	HAIRDRYER
RM0030715 	IRON
RM0030715 	MICROWAVE
RM0030715 	AIR_CONDITION
RM0030715 	FRIDGE
RM0030715 	WIFI
RM0030715 	MINIBAR
RM0030715 	SAFE
RM0030715 	COFFEE_MAKER
RM0030715 	DESK
RM0030716 	HAIRDRYER
RM0030716 	FRIDGE
RM0030800 	MINIBAR
RM0030800 	SAFE
RM0030800 	WIFI
RM0030801 	HAIRDRYER
RM0030801 	TV
RM0030801 	SAFE
RM0030801 	MICROWAVE
RM0030801 	COFFEE_MAKER
RM0030802 	DESK
RM0030802 	AIR_CONDITION
RM0030802 	MICROWAVE
RM0030802 	MINIBAR
RM0030802 	WIFI
RM0030803 	HAIRDRYER
RM0030803 	IRON
RM0030803 	DESK
RM0030803 	COFFEE_MAKER
RM0030804 	AIR_CONDITION
RM0030804 	MINIBAR
RM0030805 	MICROWAVE
RM0030805 	COFFEE_MAKER
RM0030805 	WIFI
RM0030806 	FRIDGE
RM0030806 	MICROWAVE
RM0030806 	WIFI
RM0030806 	TV
RM0030806 	IRON
RM0030806 	COFFEE_MAKER
RM0030807 	SAFE
RM0030807 	AIR_CONDITION
RM0030807 	DESK
RM0030807 	TV
RM0030807 	COFFEE_MAKER
RM0030807 	FRIDGE
RM0030807 	IRON
RM0030807 	MINIBAR
RM0030807 	HAIRDRYER
RM0030808 	IRON
RM0030808 	DESK
RM0030808 	WIFI
RM0030808 	FRIDGE
RM0030808 	SAFE
RM0030808 	AIR_CONDITION
RM0030808 	HAIRDRYER
RM0030808 	TV
RM0030809 	SAFE
RM0030810 	HAIRDRYER
RM0030810 	AIR_CONDITION
RM0030810 	WIFI
RM0030810 	TV
RM0030810 	DESK
RM0030811 	AIR_CONDITION
RM0030811 	MICROWAVE
RM0030811 	SAFE
RM0030811 	COFFEE_MAKER
RM0030811 	HAIRDRYER
RM0030811 	MINIBAR
RM0030811 	DESK
RM0030811 	TV
RM0030811 	FRIDGE
RM0030812 	SAFE
RM0030813 	COFFEE_MAKER
RM0030813 	MINIBAR
RM0030813 	MICROWAVE
RM0030813 	HAIRDRYER
RM0030813 	DESK
RM0030813 	TV
RM0030813 	WIFI
RM0030813 	FRIDGE
RM0030813 	SAFE
RM0030813 	IRON
RM0030814 	MINIBAR
RM0030815 	IRON
RM0030815 	DESK
RM0030900 	WIFI
RM0030900 	DESK
RM0030901 	COFFEE_MAKER
RM0030902 	AIR_CONDITION
RM0030902 	SAFE
RM0030902 	TV
RM0030902 	HAIRDRYER
RM0030902 	IRON
RM0030902 	WIFI
RM0030902 	MINIBAR
RM0030902 	COFFEE_MAKER
RM0030902 	FRIDGE
RM0030902 	MICROWAVE
RM0030902 	DESK
RM0030903 	MICROWAVE
RM0030903 	TV
RM0030903 	SAFE
RM0030903 	WIFI
RM0030903 	FRIDGE
RM0030903 	HAIRDRYER
RM0030904 	COFFEE_MAKER
RM0030905 	DESK
RM0030905 	MICROWAVE
RM0030906 	FRIDGE
RM0030906 	SAFE
RM0030906 	IRON
RM0030906 	COFFEE_MAKER
RM0030906 	TV
RM0030906 	WIFI
RM0030906 	MINIBAR
RM0030906 	AIR_CONDITION
RM0030907 	FRIDGE
RM0030908 	SAFE
RM0030908 	AIR_CONDITION
RM0030908 	COFFEE_MAKER
RM0030908 	IRON
RM0030908 	MINIBAR
RM0030909 	IRON
RM0030909 	TV
RM0030909 	FRIDGE
RM0031000 	AIR_CONDITION
RM0031000 	MINIBAR
RM0031000 	HAIRDRYER
RM0031000 	SAFE
RM0031000 	MICROWAVE
RM0031000 	DESK
RM0031001 	FRIDGE
RM0031001 	MINIBAR
RM0031001 	IRON
RM0031001 	HAIRDRYER
RM0031001 	MICROWAVE
RM0031001 	COFFEE_MAKER
RM0031001 	DESK
RM0031001 	TV
RM0031001 	WIFI
RM0031002 	FRIDGE
RM0031002 	SAFE
RM0031002 	AIR_CONDITION
RM0031002 	IRON
RM0031002 	TV
RM0031003 	HAIRDRYER
RM0031003 	TV
RM0031003 	WIFI
RM0031003 	MINIBAR
RM0031003 	DESK
RM0031004 	WIFI
RM0031004 	MICROWAVE
RM0031004 	FRIDGE
RM0031004 	DESK
RM0031004 	COFFEE_MAKER
RM0031004 	SAFE
RM0031004 	MINIBAR
RM0031004 	HAIRDRYER
RM0031004 	TV
RM0031004 	AIR_CONDITION
RM0031004 	IRON
RM0031005 	COFFEE_MAKER
RM0031005 	MICROWAVE
RM0031005 	AIR_CONDITION
RM0031005 	FRIDGE
RM0031006 	MICROWAVE
RM0031007 	AIR_CONDITION
RM0031007 	HAIRDRYER
RM0031007 	DESK
RM0031007 	SAFE
RM0031007 	MINIBAR
RM0031007 	FRIDGE
RM0031007 	WIFI
RM0031007 	MICROWAVE
RM0031007 	TV
RM0031008 	DESK
RM0031008 	FRIDGE
RM0031008 	COFFEE_MAKER
RM0031008 	TV
RM0031008 	WIFI
RM0031009 	FRIDGE
RM0031009 	WIFI
RM0031009 	TV
RM0031010 	HAIRDRYER
RM0031011 	AIR_CONDITION
RM0031011 	WIFI
RM0031011 	HAIRDRYER
RM0031011 	COFFEE_MAKER
RM0031012 	WIFI
RM0031012 	TV
RM0031012 	SAFE
RM0031012 	MINIBAR
RM0031012 	AIR_CONDITION
RM0031012 	IRON
RM0031012 	DESK
RM0031013 	TV
RM0031013 	FRIDGE
RM0031013 	HAIRDRYER
RM0031013 	MINIBAR
RM0031013 	MICROWAVE
RM0031013 	WIFI
RM0031013 	DESK
RM0031014 	DESK
RM0031014 	COFFEE_MAKER
RM0031014 	WIFI
RM0031014 	HAIRDRYER
RM0031014 	MINIBAR
RM0031014 	SAFE
RM0031014 	MICROWAVE
RM0031014 	TV
RM0031015 	MICROWAVE
RM0031015 	MINIBAR
RM0031015 	IRON
RM0031015 	FRIDGE
RM0031015 	COFFEE_MAKER
RM0031015 	TV
RM0031015 	SAFE
RM0031015 	WIFI
RM0031015 	AIR_CONDITION
RM0031015 	HAIRDRYER
RM0031016 	HAIRDRYER
RM0031016 	DESK
RM0031016 	FRIDGE
RM0031016 	MINIBAR
RM0031016 	TV
RM0031100 	WIFI
RM0031100 	MINIBAR
RM0031100 	MICROWAVE
RM0031100 	IRON
RM0031100 	COFFEE_MAKER
RM0031100 	FRIDGE
RM0031100 	HAIRDRYER
RM0031101 	MICROWAVE
RM0031101 	AIR_CONDITION
RM0031101 	SAFE
RM0031101 	HAIRDRYER
RM0031101 	MINIBAR
RM0031101 	FRIDGE
RM0031101 	TV
RM0031102 	TV
RM0031102 	MINIBAR
RM0031102 	HAIRDRYER
RM0031103 	COFFEE_MAKER
RM0031103 	FRIDGE
RM0031103 	IRON
RM0031103 	AIR_CONDITION
RM0031103 	SAFE
RM0031103 	DESK
RM0031104 	DESK
RM0031105 	IRON
RM0031105 	COFFEE_MAKER
RM0031105 	MICROWAVE
RM0031105 	TV
RM0031105 	FRIDGE
RM0031106 	WIFI
RM0031106 	MICROWAVE
RM0031106 	DESK
RM0031106 	TV
RM0031106 	FRIDGE
RM0031107 	FRIDGE
RM0031107 	COFFEE_MAKER
RM0031107 	MICROWAVE
RM0031107 	AIR_CONDITION
RM0031107 	WIFI
RM0031107 	IRON
RM0031107 	HAIRDRYER
RM0031108 	COFFEE_MAKER
RM0031108 	MINIBAR
RM0031108 	TV
RM0031108 	FRIDGE
RM0031108 	DESK
RM0031108 	SAFE
RM0031108 	IRON
RM0031108 	WIFI
RM0031109 	MINIBAR
RM0031109 	TV
RM0031109 	FRIDGE
RM0031109 	SAFE
RM0031109 	AIR_CONDITION
RM0031109 	COFFEE_MAKER
RM0031109 	DESK
RM0031109 	HAIRDRYER
RM0031110 	IRON
RM0031111 	HAIRDRYER
RM0031112 	TV
RM0031112 	COFFEE_MAKER
RM0031112 	MICROWAVE
RM0031112 	MINIBAR
RM0031112 	DESK
RM0031112 	FRIDGE
RM0031112 	AIR_CONDITION
RM0031112 	IRON
RM0031112 	WIFI
RM0031113 	MINIBAR
RM0031113 	HAIRDRYER
RM0031113 	DESK
RM0031113 	MICROWAVE
RM0031113 	SAFE
RM0031114 	SAFE
RM0031114 	FRIDGE
RM0031114 	MINIBAR
RM0031114 	AIR_CONDITION
RM0031114 	DESK
RM0031114 	MICROWAVE
RM0031114 	COFFEE_MAKER
RM0031114 	WIFI
RM0031114 	HAIRDRYER
RM0031114 	TV
RM0031114 	IRON
RM0031115 	FRIDGE
RM0031115 	MINIBAR
RM0031116 	SAFE
RM0031116 	MICROWAVE
RM0031116 	COFFEE_MAKER
RM0031116 	FRIDGE
RM0031116 	DESK
RM0031116 	AIR_CONDITION
RM0031116 	WIFI
RM0031116 	IRON
RM0031116 	MINIBAR
RM0031116 	HAIRDRYER
RM0031117 	HAIRDRYER
RM0031117 	DESK
RM0031117 	MINIBAR
RM0031117 	AIR_CONDITION
RM0031117 	IRON
RM0031118 	MICROWAVE
RM0031118 	MINIBAR
RM0031118 	TV
RM0031118 	AIR_CONDITION
RM0031118 	SAFE
RM0031118 	WIFI
RM0031118 	COFFEE_MAKER
RM0031118 	DESK
RM0031118 	IRON
RM0031118 	HAIRDRYER
RM0031200 	COFFEE_MAKER
RM0031200 	IRON
RM0031200 	DESK
RM0031200 	FRIDGE
RM0031200 	WIFI
RM0031200 	HAIRDRYER
RM0031200 	MINIBAR
RM0031201 	HAIRDRYER
RM0031201 	FRIDGE
RM0031201 	IRON
RM0031201 	TV
RM0031201 	DESK
RM0031202 	IRON
RM0031202 	HAIRDRYER
RM0031202 	MINIBAR
RM0031202 	FRIDGE
RM0031202 	MICROWAVE
RM0031202 	WIFI
RM0031202 	AIR_CONDITION
RM0031203 	TV
RM0031203 	AIR_CONDITION
RM0031203 	MINIBAR
RM0031204 	HAIRDRYER
RM0031204 	FRIDGE
RM0031204 	MINIBAR
RM0031204 	MICROWAVE
RM0031204 	DESK
RM0031204 	TV
RM0031204 	IRON
RM0031204 	SAFE
RM0031204 	COFFEE_MAKER
RM0031204 	WIFI
RM0031205 	IRON
RM0031205 	SAFE
RM0031205 	AIR_CONDITION
RM0031205 	WIFI
RM0031205 	MINIBAR
RM0031205 	COFFEE_MAKER
RM0031205 	MICROWAVE
RM0031206 	COFFEE_MAKER
RM0031206 	AIR_CONDITION
RM0031206 	HAIRDRYER
RM0031207 	WIFI
RM0031207 	IRON
RM0031207 	MICROWAVE
RM0031207 	HAIRDRYER
RM0031207 	AIR_CONDITION
RM0031208 	MINIBAR
RM0031208 	TV
RM0031208 	MICROWAVE
RM0031208 	WIFI
RM0031208 	IRON
RM0031208 	COFFEE_MAKER
RM0031208 	AIR_CONDITION
RM0031208 	HAIRDRYER
RM0031208 	FRIDGE
RM0031208 	DESK
RM0031208 	SAFE
RM0031209 	TV
RM0031209 	AIR_CONDITION
RM0031209 	MINIBAR
RM0031209 	HAIRDRYER
RM0031209 	COFFEE_MAKER
RM0031209 	DESK
RM0031209 	FRIDGE
RM0031210 	FRIDGE
RM0031210 	MICROWAVE
RM0031210 	MINIBAR
RM0031210 	AIR_CONDITION
RM0031210 	COFFEE_MAKER
RM0031210 	SAFE
RM0031210 	DESK
RM0031210 	HAIRDRYER
RM0031210 	WIFI
RM0031210 	IRON
RM0031210 	TV
RM0031211 	FRIDGE
RM0031212 	MICROWAVE
RM0031212 	DESK
RM0031212 	AIR_CONDITION
RM0031212 	HAIRDRYER
RM0031212 	SAFE
RM0031212 	FRIDGE
RM0031212 	IRON
RM0031212 	TV
RM0031212 	COFFEE_MAKER
RM0031212 	WIFI
RM0031212 	MINIBAR
RM0031213 	DESK
RM0031213 	SAFE
RM0031213 	AIR_CONDITION
RM0031213 	MICROWAVE
RM0031213 	TV
RM0031213 	FRIDGE
RM0031213 	WIFI
RM0031214 	HAIRDRYER
RM0031214 	MINIBAR
RM0031214 	DESK
RM0031214 	FRIDGE
RM0031214 	SAFE
RM0031214 	AIR_CONDITION
RM0031214 	MICROWAVE
RM0031214 	COFFEE_MAKER
RM0031215 	IRON
RM0031215 	MICROWAVE
RM0031215 	COFFEE_MAKER
RM0031215 	SAFE
RM0031215 	HAIRDRYER
RM0031216 	DESK
RM0031216 	HAIRDRYER
RM0031216 	FRIDGE
RM0031216 	WIFI
RM0031216 	SAFE
RM0031216 	AIR_CONDITION
RM0031216 	COFFEE_MAKER
RM0031216 	TV
RM0031300 	SAFE
RM0031300 	AIR_CONDITION
RM0031300 	HAIRDRYER
RM0031300 	FRIDGE
RM0031301 	HAIRDRYER
RM0031301 	TV
RM0031301 	SAFE
RM0031302 	COFFEE_MAKER
RM0031303 	AIR_CONDITION
RM0031303 	MINIBAR
RM0031303 	FRIDGE
RM0031303 	COFFEE_MAKER
RM0031303 	DESK
RM0031303 	SAFE
RM0031303 	WIFI
RM0031303 	TV
RM0031303 	IRON
RM0031303 	HAIRDRYER
RM0031303 	MICROWAVE
RM0031304 	COFFEE_MAKER
RM0031304 	MICROWAVE
RM0031304 	TV
RM0031304 	IRON
RM0031304 	HAIRDRYER
RM0031304 	DESK
RM0031304 	WIFI
RM0031304 	AIR_CONDITION
RM0031305 	MINIBAR
RM0031305 	COFFEE_MAKER
RM0031305 	AIR_CONDITION
RM0031305 	WIFI
RM0031305 	SAFE
RM0031305 	FRIDGE
RM0031305 	MICROWAVE
RM0031305 	DESK
RM0031306 	SAFE
RM0031306 	WIFI
RM0031306 	FRIDGE
RM0031307 	TV
RM0031307 	AIR_CONDITION
RM0031307 	MICROWAVE
RM0031308 	FRIDGE
RM0031308 	MICROWAVE
RM0031308 	DESK
RM0031308 	WIFI
RM0031308 	TV
RM0031308 	COFFEE_MAKER
RM0031308 	IRON
RM0031308 	AIR_CONDITION
RM0031308 	HAIRDRYER
RM0031309 	WIFI
RM0031309 	HAIRDRYER
RM0031309 	FRIDGE
RM0031309 	IRON
RM0031309 	MINIBAR
RM0031309 	AIR_CONDITION
RM0031309 	MICROWAVE
RM0031309 	SAFE
RM0031309 	DESK
RM0031309 	TV
RM0031310 	TV
RM0031310 	DESK
RM0031310 	WIFI
RM0031310 	COFFEE_MAKER
RM0031310 	MINIBAR
RM0031310 	MICROWAVE
RM0031310 	HAIRDRYER
RM0031310 	FRIDGE
RM0031310 	AIR_CONDITION
RM0031310 	IRON
RM0031310 	SAFE
RM0031311 	MICROWAVE
RM0031311 	FRIDGE
RM0031311 	IRON
RM0031311 	HAIRDRYER
RM0031311 	AIR_CONDITION
RM0031311 	DESK
RM0031311 	WIFI
RM0031311 	SAFE
RM0031311 	MINIBAR
RM0031311 	COFFEE_MAKER
RM0031311 	TV
RM0031312 	FRIDGE
RM0031312 	MICROWAVE
RM0031312 	AIR_CONDITION
RM0031312 	COFFEE_MAKER
RM0031312 	SAFE
RM0031312 	WIFI
RM0031312 	HAIRDRYER
RM0031312 	MINIBAR
RM0031312 	DESK
RM0031312 	TV
RM0031400 	COFFEE_MAKER
RM0031400 	WIFI
RM0031400 	MICROWAVE
RM0031400 	AIR_CONDITION
RM0031400 	HAIRDRYER
RM0031400 	SAFE
RM0031401 	WIFI
RM0031401 	DESK
RM0031401 	MICROWAVE
RM0031401 	SAFE
RM0031402 	MICROWAVE
RM0031402 	COFFEE_MAKER
RM0031402 	DESK
RM0031402 	IRON
RM0031402 	WIFI
RM0031402 	AIR_CONDITION
RM0031402 	TV
RM0031402 	MINIBAR
RM0031402 	SAFE
RM0031402 	FRIDGE
RM0031402 	HAIRDRYER
RM0031403 	DESK
RM0031403 	SAFE
RM0031403 	HAIRDRYER
RM0031403 	IRON
RM0031404 	FRIDGE
RM0031405 	TV
RM0031405 	MICROWAVE
RM0031405 	DESK
RM0031405 	SAFE
RM0031405 	HAIRDRYER
RM0031405 	WIFI
RM0031405 	FRIDGE
RM0031405 	MINIBAR
RM0031405 	COFFEE_MAKER
RM0031405 	IRON
RM0031405 	AIR_CONDITION
RM0031406 	SAFE
RM0031406 	TV
RM0031406 	IRON
RM0031406 	AIR_CONDITION
RM0031406 	DESK
RM0031406 	MINIBAR
RM0031406 	COFFEE_MAKER
RM0031406 	HAIRDRYER
RM0031407 	DESK
RM0031407 	COFFEE_MAKER
RM0031407 	TV
RM0031407 	FRIDGE
RM0031407 	SAFE
RM0031407 	WIFI
RM0031408 	COFFEE_MAKER
RM0031408 	IRON
RM0031408 	DESK
RM0031408 	MICROWAVE
RM0031408 	HAIRDRYER
RM0031408 	AIR_CONDITION
RM0031408 	TV
RM0031408 	SAFE
RM0031408 	MINIBAR
RM0031408 	WIFI
RM0031409 	FRIDGE
RM0031409 	SAFE
RM0031409 	IRON
RM0031409 	MICROWAVE
RM0031409 	AIR_CONDITION
RM0031409 	HAIRDRYER
RM0031409 	DESK
RM0031409 	TV
RM0031409 	WIFI
RM0031410 	DESK
RM0031410 	FRIDGE
RM0031410 	COFFEE_MAKER
RM0031410 	MINIBAR
RM0031410 	WIFI
RM0031410 	MICROWAVE
RM0031410 	TV
RM0031410 	IRON
RM0031410 	SAFE
RM0031411 	SAFE
RM0031411 	IRON
RM0031412 	HAIRDRYER
RM0031412 	IRON
RM0031412 	COFFEE_MAKER
RM0031412 	SAFE
RM0031412 	AIR_CONDITION
RM0031412 	MINIBAR
RM0031412 	WIFI
RM0031412 	DESK
RM0031413 	IRON
RM0031413 	FRIDGE
RM0031413 	DESK
RM0031413 	MICROWAVE
RM0031413 	COFFEE_MAKER
RM0031413 	SAFE
RM0031413 	WIFI
RM0031414 	MINIBAR
RM0031414 	AIR_CONDITION
RM0031414 	SAFE
RM0031414 	HAIRDRYER
RM0031414 	MICROWAVE
RM0031414 	FRIDGE
RM0031415 	MINIBAR
RM0031415 	MICROWAVE
RM0031415 	FRIDGE
RM0031415 	AIR_CONDITION
RM0031415 	DESK
RM0031415 	HAIRDRYER
RM0031415 	COFFEE_MAKER
RM0031415 	WIFI
RM0031415 	TV
RM0031500 	FRIDGE
RM0031500 	MICROWAVE
RM0031500 	HAIRDRYER
RM0031500 	MINIBAR
RM0031500 	COFFEE_MAKER
RM0031500 	AIR_CONDITION
RM0031500 	TV
RM0031500 	IRON
RM0031500 	SAFE
RM0031501 	HAIRDRYER
RM0031501 	WIFI
RM0031501 	MINIBAR
RM0031501 	IRON
RM0031501 	FRIDGE
RM0031501 	MICROWAVE
RM0031502 	WIFI
RM0031502 	DESK
RM0031502 	FRIDGE
RM0031502 	IRON
RM0031502 	AIR_CONDITION
RM0031502 	COFFEE_MAKER
RM0031502 	MICROWAVE
RM0031502 	SAFE
RM0031502 	TV
RM0031502 	HAIRDRYER
RM0031502 	MINIBAR
RM0031503 	WIFI
RM0031503 	DESK
RM0031503 	IRON
RM0031503 	COFFEE_MAKER
RM0031503 	SAFE
RM0031503 	MICROWAVE
RM0031503 	MINIBAR
RM0031503 	TV
RM0031504 	COFFEE_MAKER
RM0031504 	DESK
RM0031504 	AIR_CONDITION
RM0031504 	TV
RM0031504 	FRIDGE
RM0031504 	MINIBAR
RM0031505 	HAIRDRYER
RM0031505 	TV
RM0031505 	AIR_CONDITION
RM0031506 	IRON
RM0031506 	MINIBAR
RM0031506 	HAIRDRYER
RM0031506 	COFFEE_MAKER
RM0031506 	DESK
RM0031506 	WIFI
RM0031506 	FRIDGE
RM0031506 	SAFE
RM0031506 	TV
RM0031506 	AIR_CONDITION
RM0031507 	MINIBAR
RM0031507 	AIR_CONDITION
RM0031507 	SAFE
RM0031507 	IRON
RM0031507 	TV
RM0031508 	IRON
RM0031508 	FRIDGE
RM0031508 	MICROWAVE
RM0031508 	DESK
RM0031509 	DESK
RM0031509 	TV
RM0031509 	HAIRDRYER
RM0031509 	MICROWAVE
RM0031509 	IRON
RM0031509 	SAFE
RM0031509 	MINIBAR
RM0031510 	DESK
RM0031510 	TV
RM0031510 	AIR_CONDITION
RM0031510 	WIFI
RM0031510 	FRIDGE
RM0031510 	MICROWAVE
RM0031510 	COFFEE_MAKER
RM0031511 	WIFI
RM0031511 	FRIDGE
RM0031511 	COFFEE_MAKER
RM0031511 	MICROWAVE
RM0031511 	DESK
RM0031511 	MINIBAR
RM0031511 	SAFE
RM0031511 	AIR_CONDITION
RM0031512 	SAFE
RM0031513 	AIR_CONDITION
RM0031513 	TV
RM0031513 	MINIBAR
RM0031513 	SAFE
RM0031513 	WIFI
RM0031513 	MICROWAVE
RM0031513 	IRON
RM0031513 	COFFEE_MAKER
RM0031514 	SAFE
RM0031514 	IRON
RM0040000 	MICROWAVE
RM0040001 	MICROWAVE
RM0040001 	DESK
RM0040002 	COFFEE_MAKER
RM0040002 	AIR_CONDITION
RM0040002 	DESK
RM0040002 	HAIRDRYER
RM0040002 	IRON
RM0040002 	MICROWAVE
RM0040002 	SAFE
RM0040003 	IRON
RM0040003 	HAIRDRYER
RM0040004 	TV
RM0040004 	IRON
RM0040004 	AIR_CONDITION
RM0040004 	HAIRDRYER
RM0040005 	IRON
RM0040005 	DESK
RM0040005 	WIFI
RM0040005 	COFFEE_MAKER
RM0040005 	AIR_CONDITION
RM0040006 	WIFI
RM0040007 	COFFEE_MAKER
RM0040008 	TV
RM0040008 	SAFE
RM0040008 	MICROWAVE
RM0040008 	DESK
RM0040008 	COFFEE_MAKER
RM0040008 	MINIBAR
RM0040009 	DESK
RM0040009 	FRIDGE
RM0040009 	MINIBAR
RM0040009 	HAIRDRYER
RM0040009 	IRON
RM0040009 	WIFI
RM0040009 	AIR_CONDITION
RM0040009 	MICROWAVE
RM0040100 	DESK
RM0040100 	TV
RM0040100 	HAIRDRYER
RM0040100 	MICROWAVE
RM0040100 	IRON
RM0040100 	COFFEE_MAKER
RM0040100 	WIFI
RM0040100 	AIR_CONDITION
RM0040100 	FRIDGE
RM0040100 	SAFE
RM0040101 	FRIDGE
RM0040101 	TV
RM0040102 	HAIRDRYER
RM0040103 	DESK
RM0040103 	WIFI
RM0040103 	TV
RM0040103 	IRON
RM0040103 	SAFE
RM0040103 	MINIBAR
RM0040103 	HAIRDRYER
RM0040103 	AIR_CONDITION
RM0040104 	COFFEE_MAKER
RM0040104 	IRON
RM0040104 	MICROWAVE
RM0040104 	SAFE
RM0040104 	FRIDGE
RM0040104 	HAIRDRYER
RM0040104 	MINIBAR
RM0040104 	AIR_CONDITION
RM0040104 	DESK
RM0040104 	TV
RM0040105 	MINIBAR
RM0040105 	FRIDGE
RM0040105 	HAIRDRYER
RM0040105 	COFFEE_MAKER
RM0040105 	DESK
RM0040105 	SAFE
RM0040105 	IRON
RM0040105 	TV
RM0040105 	WIFI
RM0040106 	COFFEE_MAKER
RM0040106 	IRON
RM0040106 	MINIBAR
RM0040107 	SAFE
RM0040107 	DESK
RM0040107 	MICROWAVE
RM0040107 	HAIRDRYER
RM0040107 	WIFI
RM0040107 	IRON
RM0040107 	MINIBAR
RM0040108 	AIR_CONDITION
RM0040108 	HAIRDRYER
RM0040108 	SAFE
RM0040108 	FRIDGE
RM0040108 	WIFI
RM0040108 	MINIBAR
RM0040109 	SAFE
RM0040109 	TV
RM0040109 	FRIDGE
RM0040109 	MICROWAVE
RM0040109 	IRON
RM0040109 	DESK
RM0040109 	AIR_CONDITION
RM0040109 	MINIBAR
RM0040109 	WIFI
RM0040109 	COFFEE_MAKER
RM0040109 	HAIRDRYER
RM0040110 	MICROWAVE
RM0040110 	AIR_CONDITION
RM0040110 	WIFI
RM0040110 	TV
RM0040111 	FRIDGE
RM0040112 	WIFI
RM0040112 	IRON
RM0040112 	DESK
RM0040112 	FRIDGE
RM0040112 	MINIBAR
RM0040113 	TV
RM0040113 	DESK
RM0040113 	WIFI
RM0040113 	HAIRDRYER
RM0040113 	FRIDGE
RM0040113 	IRON
RM0040113 	AIR_CONDITION
RM0040114 	AIR_CONDITION
RM0040114 	MICROWAVE
RM0040114 	HAIRDRYER
RM0040114 	DESK
RM0040114 	WIFI
RM0040115 	WIFI
RM0040115 	SAFE
RM0040115 	FRIDGE
RM0040115 	DESK
RM0040115 	TV
RM0040115 	AIR_CONDITION
RM0040115 	MICROWAVE
RM0040115 	IRON
RM0040200 	SAFE
RM0040200 	MINIBAR
RM0040200 	TV
RM0040200 	WIFI
RM0040200 	FRIDGE
RM0040200 	DESK
RM0040200 	COFFEE_MAKER
RM0040201 	IRON
RM0040201 	AIR_CONDITION
RM0040201 	DESK
RM0040201 	MICROWAVE
RM0040201 	COFFEE_MAKER
RM0040202 	DESK
RM0040203 	DESK
RM0040203 	COFFEE_MAKER
RM0040203 	AIR_CONDITION
RM0040203 	FRIDGE
RM0040203 	IRON
RM0040203 	MINIBAR
RM0040203 	HAIRDRYER
RM0040204 	COFFEE_MAKER
RM0040204 	MICROWAVE
RM0040204 	AIR_CONDITION
RM0040204 	DESK
RM0040205 	AIR_CONDITION
RM0040205 	SAFE
RM0040205 	MINIBAR
RM0040205 	HAIRDRYER
RM0040205 	IRON
RM0040205 	TV
RM0040205 	COFFEE_MAKER
RM0040205 	MICROWAVE
RM0040205 	FRIDGE
RM0040205 	WIFI
RM0040206 	TV
RM0040206 	HAIRDRYER
RM0040206 	DESK
RM0040206 	IRON
RM0040206 	WIFI
RM0040206 	AIR_CONDITION
RM0040206 	FRIDGE
RM0040207 	DESK
RM0040207 	MICROWAVE
RM0040207 	COFFEE_MAKER
RM0040207 	HAIRDRYER
RM0040207 	WIFI
RM0040207 	IRON
RM0040207 	MINIBAR
RM0040207 	TV
RM0040208 	DESK
RM0040208 	WIFI
RM0040208 	COFFEE_MAKER
RM0040208 	MINIBAR
RM0040208 	HAIRDRYER
RM0040208 	TV
RM0040208 	MICROWAVE
RM0040209 	COFFEE_MAKER
RM0040209 	MINIBAR
RM0040209 	MICROWAVE
RM0040209 	SAFE
RM0040209 	FRIDGE
RM0040209 	TV
RM0040209 	WIFI
RM0040209 	DESK
RM0040210 	SAFE
RM0040210 	DESK
RM0040210 	MICROWAVE
RM0040210 	MINIBAR
RM0040300 	MINIBAR
RM0040300 	SAFE
RM0040300 	TV
RM0040300 	MICROWAVE
RM0040300 	HAIRDRYER
RM0040301 	FRIDGE
RM0040301 	DESK
RM0040301 	MINIBAR
RM0040301 	MICROWAVE
RM0040301 	TV
RM0040301 	SAFE
RM0040301 	COFFEE_MAKER
RM0040301 	HAIRDRYER
RM0040302 	SAFE
RM0040302 	IRON
RM0040302 	COFFEE_MAKER
RM0040302 	HAIRDRYER
RM0040302 	TV
RM0040302 	WIFI
RM0040303 	MINIBAR
RM0040303 	DESK
RM0040303 	WIFI
RM0040304 	FRIDGE
RM0040304 	MINIBAR
RM0040304 	DESK
RM0040304 	SAFE
RM0040304 	COFFEE_MAKER
RM0040304 	WIFI
RM0040304 	TV
RM0040304 	AIR_CONDITION
RM0040304 	HAIRDRYER
RM0040304 	MICROWAVE
RM0040305 	FRIDGE
RM0040305 	COFFEE_MAKER
RM0040305 	HAIRDRYER
RM0040305 	IRON
RM0040305 	SAFE
RM0040305 	TV
RM0040305 	MINIBAR
RM0040305 	DESK
RM0040306 	TV
RM0040306 	FRIDGE
RM0040306 	MICROWAVE
RM0040306 	DESK
RM0040307 	WIFI
RM0040307 	DESK
RM0040307 	SAFE
RM0040307 	COFFEE_MAKER
RM0040307 	MICROWAVE
RM0040307 	MINIBAR
RM0040307 	HAIRDRYER
RM0040307 	FRIDGE
RM0040308 	IRON
RM0040309 	WIFI
RM0040309 	AIR_CONDITION
RM0040309 	HAIRDRYER
RM0040309 	DESK
RM0040309 	TV
RM0040310 	DESK
RM0040310 	HAIRDRYER
RM0040310 	AIR_CONDITION
RM0040311 	WIFI
RM0040311 	SAFE
RM0040311 	DESK
RM0040311 	AIR_CONDITION
RM0040400 	HAIRDRYER
RM0040401 	COFFEE_MAKER
RM0040401 	AIR_CONDITION
RM0040401 	TV
RM0040401 	SAFE
RM0040401 	FRIDGE
RM0040401 	MICROWAVE
RM0040401 	WIFI
RM0040401 	HAIRDRYER
RM0040401 	IRON
RM0040401 	DESK
RM0040401 	MINIBAR
RM0040402 	TV
RM0040402 	SAFE
RM0040402 	AIR_CONDITION
RM0040402 	DESK
RM0040402 	MICROWAVE
RM0040402 	COFFEE_MAKER
RM0040402 	MINIBAR
RM0040402 	IRON
RM0040402 	FRIDGE
RM0040403 	IRON
RM0040403 	DESK
RM0040403 	WIFI
RM0040403 	FRIDGE
RM0040403 	SAFE
RM0040403 	MINIBAR
RM0040403 	AIR_CONDITION
RM0040403 	COFFEE_MAKER
RM0040403 	MICROWAVE
RM0040403 	TV
RM0040404 	MINIBAR
RM0040404 	FRIDGE
RM0040404 	DESK
RM0040404 	TV
RM0040404 	IRON
RM0040405 	TV
RM0040405 	FRIDGE
RM0040405 	HAIRDRYER
RM0040405 	MINIBAR
RM0040405 	MICROWAVE
RM0040405 	WIFI
RM0040405 	COFFEE_MAKER
RM0040405 	SAFE
RM0040405 	DESK
RM0040405 	AIR_CONDITION
RM0040405 	IRON
RM0040406 	MINIBAR
RM0040406 	MICROWAVE
RM0040406 	IRON
RM0040407 	MINIBAR
RM0040407 	AIR_CONDITION
RM0040407 	IRON
RM0040407 	TV
RM0040407 	HAIRDRYER
RM0040407 	FRIDGE
RM0040407 	MICROWAVE
RM0040407 	COFFEE_MAKER
RM0040407 	WIFI
RM0040408 	MICROWAVE
RM0040409 	MICROWAVE
RM0040409 	TV
RM0040409 	WIFI
RM0040409 	HAIRDRYER
RM0040409 	COFFEE_MAKER
RM0040409 	FRIDGE
RM0040409 	AIR_CONDITION
RM0040409 	IRON
RM0040409 	MINIBAR
RM0040410 	WIFI
RM0040410 	MICROWAVE
RM0040410 	FRIDGE
RM0040410 	MINIBAR
RM0040410 	IRON
RM0040411 	FRIDGE
RM0040411 	SAFE
RM0040411 	TV
RM0040411 	MINIBAR
RM0040411 	COFFEE_MAKER
RM0040411 	HAIRDRYER
RM0040411 	DESK
RM0040411 	MICROWAVE
RM0040411 	IRON
RM0040411 	WIFI
RM0040411 	AIR_CONDITION
RM0040412 	TV
RM0040412 	AIR_CONDITION
RM0040412 	WIFI
RM0040412 	FRIDGE
RM0040412 	SAFE
RM0040413 	FRIDGE
RM0040413 	IRON
RM0040413 	SAFE
RM0040413 	WIFI
RM0040413 	DESK
RM0040413 	HAIRDRYER
RM0040413 	MINIBAR
RM0040413 	MICROWAVE
RM0040413 	TV
RM0040414 	DESK
RM0040414 	SAFE
RM0040414 	MICROWAVE
RM0040414 	TV
RM0040415 	WIFI
RM0040416 	AIR_CONDITION
RM0040416 	COFFEE_MAKER
RM0040416 	WIFI
RM0040416 	FRIDGE
RM0040416 	HAIRDRYER
RM0040416 	MICROWAVE
RM0040416 	DESK
RM0040416 	IRON
RM0040416 	MINIBAR
RM0040500 	FRIDGE
RM0040500 	MICROWAVE
RM0040500 	AIR_CONDITION
RM0040500 	SAFE
RM0040500 	HAIRDRYER
RM0040500 	MINIBAR
RM0040500 	TV
RM0040500 	WIFI
RM0040500 	DESK
RM0040500 	IRON
RM0040500 	COFFEE_MAKER
RM0040501 	IRON
RM0040501 	FRIDGE
RM0040501 	DESK
RM0040501 	COFFEE_MAKER
RM0040501 	HAIRDRYER
RM0040501 	SAFE
RM0040501 	MICROWAVE
RM0040501 	TV
RM0040501 	AIR_CONDITION
RM0040501 	WIFI
RM0040501 	MINIBAR
RM0040502 	IRON
RM0040502 	COFFEE_MAKER
RM0040503 	SAFE
RM0040503 	DESK
RM0040503 	FRIDGE
RM0040503 	WIFI
RM0040504 	MINIBAR
RM0040504 	IRON
RM0040504 	FRIDGE
RM0040504 	SAFE
RM0040504 	AIR_CONDITION
RM0040504 	MICROWAVE
RM0040505 	IRON
RM0040505 	TV
RM0040505 	COFFEE_MAKER
RM0040505 	DESK
RM0040505 	HAIRDRYER
RM0040505 	MINIBAR
RM0040505 	AIR_CONDITION
RM0040505 	FRIDGE
RM0040505 	MICROWAVE
RM0040506 	FRIDGE
RM0040506 	WIFI
RM0040507 	SAFE
RM0040507 	IRON
RM0040507 	HAIRDRYER
RM0040507 	WIFI
RM0040507 	DESK
RM0040507 	MICROWAVE
RM0040508 	FRIDGE
RM0040508 	DESK
RM0040508 	COFFEE_MAKER
RM0040508 	TV
RM0040508 	MICROWAVE
RM0040508 	SAFE
RM0040509 	TV
RM0040509 	SAFE
RM0040509 	DESK
RM0040509 	IRON
RM0040509 	AIR_CONDITION
RM0040509 	FRIDGE
RM0040509 	HAIRDRYER
RM0040509 	COFFEE_MAKER
RM0040509 	WIFI
RM0040509 	MINIBAR
RM0040509 	MICROWAVE
RM0040510 	MICROWAVE
RM0040510 	SAFE
RM0040511 	MINIBAR
RM0040511 	HAIRDRYER
RM0040511 	SAFE
RM0040511 	DESK
RM0040511 	COFFEE_MAKER
RM0040511 	IRON
RM0040511 	MICROWAVE
RM0040511 	FRIDGE
RM0040511 	TV
RM0040512 	DESK
RM0040512 	AIR_CONDITION
RM0040512 	IRON
RM0040512 	MINIBAR
RM0040512 	HAIRDRYER
RM0040512 	MICROWAVE
RM0040512 	SAFE
RM0040512 	FRIDGE
RM0040512 	COFFEE_MAKER
RM0040512 	WIFI
RM0040512 	TV
RM0040513 	MICROWAVE
RM0040513 	DESK
RM0040513 	COFFEE_MAKER
RM0040514 	AIR_CONDITION
RM0040514 	FRIDGE
RM0040515 	MINIBAR
RM0040516 	COFFEE_MAKER
RM0040600 	IRON
RM0040600 	SAFE
RM0040601 	MICROWAVE
RM0040601 	HAIRDRYER
RM0040601 	SAFE
RM0040601 	TV
RM0040601 	DESK
RM0040601 	WIFI
RM0040602 	DESK
RM0040602 	FRIDGE
RM0040602 	SAFE
RM0040602 	WIFI
RM0040602 	TV
RM0040602 	AIR_CONDITION
RM0040602 	COFFEE_MAKER
RM0040603 	AIR_CONDITION
RM0040603 	DESK
RM0040603 	HAIRDRYER
RM0040604 	AIR_CONDITION
RM0040604 	WIFI
RM0040605 	MICROWAVE
RM0040605 	AIR_CONDITION
RM0040605 	WIFI
RM0040605 	COFFEE_MAKER
RM0040605 	IRON
RM0040605 	HAIRDRYER
RM0040605 	DESK
RM0040605 	FRIDGE
RM0040606 	WIFI
RM0040606 	MINIBAR
RM0040606 	MICROWAVE
RM0040606 	AIR_CONDITION
RM0040606 	TV
RM0040606 	COFFEE_MAKER
RM0040606 	DESK
RM0040606 	FRIDGE
RM0040606 	SAFE
RM0040606 	IRON
RM0040606 	HAIRDRYER
RM0040607 	FRIDGE
RM0040607 	MICROWAVE
RM0040607 	COFFEE_MAKER
RM0040607 	DESK
RM0040607 	SAFE
RM0040607 	AIR_CONDITION
RM0040608 	HAIRDRYER
RM0040608 	COFFEE_MAKER
RM0040608 	SAFE
RM0040608 	MICROWAVE
RM0040608 	AIR_CONDITION
RM0040608 	WIFI
RM0040608 	TV
RM0040609 	TV
RM0040609 	FRIDGE
RM0040609 	SAFE
RM0040610 	HAIRDRYER
RM0040610 	MINIBAR
RM0040610 	WIFI
RM0040610 	MICROWAVE
RM0040610 	TV
RM0040610 	AIR_CONDITION
RM0040611 	TV
RM0040611 	MICROWAVE
RM0040611 	SAFE
RM0040611 	IRON
RM0040611 	WIFI
RM0040611 	AIR_CONDITION
RM0040611 	FRIDGE
RM0040612 	IRON
RM0040612 	MICROWAVE
RM0040612 	AIR_CONDITION
RM0040612 	FRIDGE
RM0040613 	MICROWAVE
RM0040613 	MINIBAR
RM0040613 	SAFE
RM0040613 	COFFEE_MAKER
RM0040613 	DESK
RM0040613 	TV
RM0040613 	AIR_CONDITION
RM0040614 	HAIRDRYER
RM0040614 	TV
RM0040614 	WIFI
RM0040614 	MINIBAR
RM0040614 	FRIDGE
RM0040615 	MICROWAVE
RM0040615 	WIFI
RM0040615 	IRON
RM0040615 	DESK
RM0040700 	HAIRDRYER
RM0040701 	SAFE
RM0040701 	MINIBAR
RM0040701 	MICROWAVE
RM0040701 	IRON
RM0040701 	AIR_CONDITION
RM0040701 	WIFI
RM0040701 	DESK
RM0040701 	TV
RM0040701 	HAIRDRYER
RM0040701 	COFFEE_MAKER
RM0040701 	FRIDGE
RM0040702 	WIFI
RM0040702 	FRIDGE
RM0040702 	HAIRDRYER
RM0040702 	DESK
RM0040702 	TV
RM0040702 	MICROWAVE
RM0040702 	MINIBAR
RM0040702 	IRON
RM0040702 	SAFE
RM0040703 	WIFI
RM0040703 	TV
RM0040703 	FRIDGE
RM0040704 	AIR_CONDITION
RM0040704 	MICROWAVE
RM0040705 	HAIRDRYER
RM0040705 	MINIBAR
RM0040705 	AIR_CONDITION
RM0040705 	SAFE
RM0040705 	WIFI
RM0040705 	MICROWAVE
RM0040705 	DESK
RM0040706 	IRON
RM0040706 	MINIBAR
RM0040706 	DESK
RM0040706 	MICROWAVE
RM0040706 	WIFI
RM0040706 	COFFEE_MAKER
RM0040706 	SAFE
RM0040707 	IRON
RM0040707 	TV
RM0040707 	MINIBAR
RM0040707 	FRIDGE
RM0040708 	AIR_CONDITION
RM0040709 	TV
RM0040709 	MICROWAVE
RM0040709 	SAFE
RM0040709 	DESK
RM0040709 	AIR_CONDITION
RM0040709 	WIFI
RM0040709 	IRON
RM0040709 	COFFEE_MAKER
RM0040709 	FRIDGE
RM0040709 	HAIRDRYER
RM0040709 	MINIBAR
RM0040710 	MINIBAR
RM0040710 	IRON
RM0040710 	FRIDGE
RM0040710 	AIR_CONDITION
RM0040710 	MICROWAVE
RM0040710 	TV
RM0040710 	COFFEE_MAKER
RM0040711 	DESK
RM0040711 	MINIBAR
RM0040711 	FRIDGE
RM0040711 	IRON
RM0040711 	HAIRDRYER
RM0040711 	TV
RM0040711 	COFFEE_MAKER
RM0040711 	AIR_CONDITION
RM0040711 	SAFE
RM0040711 	WIFI
RM0040711 	MICROWAVE
RM0040712 	TV
RM0040712 	WIFI
RM0040712 	MICROWAVE
RM0040712 	COFFEE_MAKER
RM0040712 	DESK
RM0040713 	FRIDGE
RM0040714 	WIFI
RM0040714 	COFFEE_MAKER
RM0040714 	MINIBAR
RM0040714 	TV
RM0040714 	IRON
RM0040714 	FRIDGE
RM0040800 	WIFI
RM0040800 	COFFEE_MAKER
RM0040800 	MICROWAVE
RM0040800 	HAIRDRYER
RM0040800 	DESK
RM0040800 	FRIDGE
RM0040800 	SAFE
RM0040800 	MINIBAR
RM0040800 	AIR_CONDITION
RM0040800 	TV
RM0040800 	IRON
RM0040801 	WIFI
RM0040801 	COFFEE_MAKER
RM0040802 	WIFI
RM0040802 	MINIBAR
RM0040802 	SAFE
RM0040802 	FRIDGE
RM0040802 	TV
RM0040802 	HAIRDRYER
RM0040802 	COFFEE_MAKER
RM0040802 	DESK
RM0040802 	AIR_CONDITION
RM0040802 	MICROWAVE
RM0040803 	FRIDGE
RM0040803 	TV
RM0040803 	MICROWAVE
RM0040803 	SAFE
RM0040804 	FRIDGE
RM0040804 	DESK
RM0040804 	IRON
RM0040804 	SAFE
RM0040804 	MINIBAR
RM0040804 	HAIRDRYER
RM0040804 	TV
RM0040804 	COFFEE_MAKER
RM0040805 	AIR_CONDITION
RM0040805 	FRIDGE
RM0040805 	WIFI
RM0040805 	MICROWAVE
RM0040805 	MINIBAR
RM0040805 	SAFE
RM0040805 	TV
RM0040805 	IRON
RM0040806 	WIFI
RM0040806 	DESK
RM0040806 	MINIBAR
RM0040806 	AIR_CONDITION
RM0040806 	COFFEE_MAKER
RM0040806 	IRON
RM0040806 	SAFE
RM0040806 	HAIRDRYER
RM0040806 	FRIDGE
RM0040806 	MICROWAVE
RM0040807 	WIFI
RM0040807 	FRIDGE
RM0040807 	DESK
RM0040807 	COFFEE_MAKER
RM0040807 	IRON
RM0040807 	HAIRDRYER
RM0040808 	FRIDGE
RM0040808 	WIFI
RM0040808 	DESK
RM0040808 	COFFEE_MAKER
RM0040808 	IRON
RM0040808 	HAIRDRYER
RM0040808 	SAFE
RM0040808 	MICROWAVE
RM0040808 	AIR_CONDITION
RM0040808 	TV
RM0040809 	MINIBAR
RM0040809 	MICROWAVE
RM0040809 	SAFE
RM0040809 	TV
RM0040810 	HAIRDRYER
RM0040810 	AIR_CONDITION
RM0040810 	IRON
RM0040810 	FRIDGE
RM0040810 	SAFE
RM0040810 	TV
RM0040810 	WIFI
RM0040810 	MINIBAR
RM0040810 	COFFEE_MAKER
RM0040810 	DESK
RM0040810 	MICROWAVE
RM0040811 	MINIBAR
RM0040811 	COFFEE_MAKER
RM0040811 	WIFI
RM0040811 	IRON
RM0040811 	FRIDGE
RM0040811 	TV
RM0040811 	AIR_CONDITION
RM0040811 	HAIRDRYER
RM0040900 	MINIBAR
RM0040900 	DESK
RM0040901 	AIR_CONDITION
RM0040901 	IRON
RM0040901 	SAFE
RM0040901 	MICROWAVE
RM0040902 	WIFI
RM0040902 	MICROWAVE
RM0040902 	AIR_CONDITION
RM0040902 	COFFEE_MAKER
RM0040902 	HAIRDRYER
RM0040903 	WIFI
RM0040903 	MINIBAR
RM0040903 	FRIDGE
RM0040904 	COFFEE_MAKER
RM0040905 	HAIRDRYER
RM0040906 	MICROWAVE
RM0040906 	TV
RM0040906 	IRON
RM0040906 	AIR_CONDITION
RM0040906 	COFFEE_MAKER
RM0040906 	WIFI
RM0040907 	HAIRDRYER
RM0040907 	AIR_CONDITION
RM0040907 	DESK
RM0040908 	DESK
RM0040908 	IRON
RM0040908 	MINIBAR
RM0040908 	COFFEE_MAKER
RM0040908 	HAIRDRYER
RM0040908 	FRIDGE
RM0040908 	TV
RM0040908 	SAFE
RM0040908 	MICROWAVE
RM0040909 	WIFI
RM0040909 	FRIDGE
RM0040909 	AIR_CONDITION
RM0040910 	TV
RM0040910 	WIFI
RM0041000 	MINIBAR
RM0041000 	DESK
RM0041000 	HAIRDRYER
RM0041000 	WIFI
RM0041000 	TV
RM0041000 	FRIDGE
RM0041000 	SAFE
RM0041000 	IRON
RM0041000 	COFFEE_MAKER
RM0041000 	MICROWAVE
RM0041000 	AIR_CONDITION
RM0041001 	MINIBAR
RM0041001 	HAIRDRYER
RM0041001 	WIFI
RM0041001 	IRON
RM0041001 	SAFE
RM0041001 	TV
RM0041002 	HAIRDRYER
RM0041002 	SAFE
RM0041002 	COFFEE_MAKER
RM0041002 	MINIBAR
RM0041002 	FRIDGE
RM0041002 	WIFI
RM0041002 	AIR_CONDITION
RM0041002 	DESK
RM0041002 	MICROWAVE
RM0041002 	IRON
RM0041002 	TV
RM0041003 	MINIBAR
RM0041003 	MICROWAVE
RM0041003 	WIFI
RM0041003 	FRIDGE
RM0041003 	DESK
RM0041003 	HAIRDRYER
RM0041003 	IRON
RM0041003 	SAFE
RM0041003 	AIR_CONDITION
RM0041003 	TV
RM0041004 	COFFEE_MAKER
RM0041004 	MICROWAVE
RM0041004 	IRON
RM0041004 	AIR_CONDITION
RM0041004 	MINIBAR
RM0041005 	HAIRDRYER
RM0041005 	AIR_CONDITION
RM0041005 	MINIBAR
RM0041005 	TV
RM0041005 	MICROWAVE
RM0041006 	SAFE
RM0041006 	AIR_CONDITION
RM0041006 	HAIRDRYER
RM0041006 	COFFEE_MAKER
RM0041007 	FRIDGE
RM0041007 	IRON
RM0041007 	TV
RM0041007 	COFFEE_MAKER
RM0041007 	DESK
RM0041007 	MINIBAR
RM0041007 	WIFI
RM0041007 	SAFE
RM0041007 	MICROWAVE
RM0041008 	IRON
RM0041008 	AIR_CONDITION
RM0041008 	TV
RM0041008 	MICROWAVE
RM0041008 	SAFE
RM0041008 	WIFI
RM0041009 	MICROWAVE
RM0041009 	AIR_CONDITION
RM0041009 	DESK
RM0041009 	FRIDGE
RM0041009 	TV
RM0041010 	COFFEE_MAKER
RM0041010 	SAFE
RM0041010 	TV
RM0041010 	HAIRDRYER
RM0041010 	FRIDGE
RM0041010 	WIFI
RM0041010 	IRON
RM0041010 	MICROWAVE
RM0041010 	DESK
RM0041010 	MINIBAR
RM0041011 	WIFI
RM0041011 	DESK
RM0041011 	MICROWAVE
RM0041011 	AIR_CONDITION
RM0041011 	MINIBAR
RM0041011 	COFFEE_MAKER
RM0041011 	TV
RM0041011 	IRON
RM0041011 	HAIRDRYER
RM0041011 	FRIDGE
RM0041012 	FRIDGE
RM0041012 	MINIBAR
RM0041012 	SAFE
RM0041012 	COFFEE_MAKER
RM0041012 	MICROWAVE
RM0041012 	AIR_CONDITION
RM0041012 	IRON
RM0041012 	WIFI
RM0041012 	TV
RM0041012 	DESK
RM0041013 	SAFE
RM0041013 	DESK
RM0041013 	IRON
RM0041013 	TV
RM0041013 	HAIRDRYER
RM0041013 	MINIBAR
RM0041013 	WIFI
RM0041013 	MICROWAVE
RM0041014 	WIFI
RM0041014 	HAIRDRYER
RM0041100 	SAFE
RM0041100 	MICROWAVE
RM0041100 	FRIDGE
RM0041100 	TV
RM0041100 	MINIBAR
RM0041100 	COFFEE_MAKER
RM0041100 	HAIRDRYER
RM0041101 	FRIDGE
RM0041101 	IRON
RM0041101 	COFFEE_MAKER
RM0041101 	SAFE
RM0041101 	DESK
RM0041101 	MINIBAR
RM0041102 	MINIBAR
RM0041102 	HAIRDRYER
RM0041103 	MINIBAR
RM0041103 	MICROWAVE
RM0041103 	WIFI
RM0041103 	SAFE
RM0041103 	AIR_CONDITION
RM0041104 	MICROWAVE
RM0041105 	COFFEE_MAKER
RM0041105 	FRIDGE
RM0041105 	MINIBAR
RM0041105 	DESK
RM0041105 	AIR_CONDITION
RM0041105 	TV
RM0041105 	HAIRDRYER
RM0041105 	MICROWAVE
RM0041105 	SAFE
RM0041105 	WIFI
RM0041105 	IRON
RM0041106 	TV
RM0041106 	SAFE
RM0041106 	FRIDGE
RM0041107 	AIR_CONDITION
RM0041107 	SAFE
RM0041107 	HAIRDRYER
RM0041107 	MINIBAR
RM0041107 	TV
RM0041107 	DESK
RM0041107 	IRON
RM0041107 	COFFEE_MAKER
RM0041107 	MICROWAVE
RM0041107 	WIFI
RM0041107 	FRIDGE
RM0041108 	DESK
RM0041108 	MINIBAR
RM0041108 	WIFI
RM0041108 	IRON
RM0041108 	AIR_CONDITION
RM0041108 	COFFEE_MAKER
RM0041108 	TV
RM0041109 	SAFE
RM0041109 	MICROWAVE
RM0041109 	FRIDGE
RM0041109 	HAIRDRYER
RM0041109 	AIR_CONDITION
RM0041109 	WIFI
RM0041109 	COFFEE_MAKER
RM0041109 	IRON
RM0041110 	MICROWAVE
RM0041110 	FRIDGE
RM0041110 	WIFI
RM0041110 	HAIRDRYER
RM0041110 	IRON
RM0041111 	HAIRDRYER
RM0041111 	IRON
RM0041111 	DESK
RM0041111 	COFFEE_MAKER
RM0041111 	AIR_CONDITION
RM0041111 	FRIDGE
RM0041111 	MICROWAVE
RM0041111 	SAFE
RM0041111 	MINIBAR
RM0041112 	HAIRDRYER
RM0041112 	DESK
RM0041112 	WIFI
RM0041112 	MINIBAR
RM0041112 	MICROWAVE
RM0041112 	AIR_CONDITION
RM0041112 	TV
RM0041112 	IRON
RM0041112 	FRIDGE
RM0041112 	SAFE
RM0041112 	COFFEE_MAKER
RM0041113 	FRIDGE
RM0041113 	IRON
RM0041113 	DESK
RM0041113 	HAIRDRYER
RM0041113 	AIR_CONDITION
RM0041113 	COFFEE_MAKER
RM0041114 	COFFEE_MAKER
RM0041114 	AIR_CONDITION
RM0041114 	MINIBAR
RM0041114 	TV
RM0041114 	SAFE
RM0041114 	HAIRDRYER
RM0041114 	FRIDGE
RM0041114 	DESK
RM0041200 	AIR_CONDITION
RM0041200 	SAFE
RM0041200 	IRON
RM0041200 	FRIDGE
RM0041200 	MICROWAVE
RM0041201 	FRIDGE
RM0041201 	SAFE
RM0041202 	DESK
RM0041202 	SAFE
RM0041202 	MINIBAR
RM0041202 	COFFEE_MAKER
RM0041203 	SAFE
RM0041203 	AIR_CONDITION
RM0041203 	IRON
RM0041203 	TV
RM0041203 	MICROWAVE
RM0041203 	WIFI
RM0041203 	COFFEE_MAKER
RM0041203 	HAIRDRYER
RM0041203 	FRIDGE
RM0041203 	MINIBAR
RM0041203 	DESK
RM0041204 	AIR_CONDITION
RM0041204 	TV
RM0041204 	COFFEE_MAKER
RM0041204 	IRON
RM0041204 	FRIDGE
RM0041204 	WIFI
RM0041205 	FRIDGE
RM0041205 	TV
RM0041205 	MINIBAR
RM0041205 	DESK
RM0041205 	IRON
RM0041205 	WIFI
RM0041205 	SAFE
RM0041205 	AIR_CONDITION
RM0041205 	COFFEE_MAKER
RM0041205 	MICROWAVE
RM0041206 	WIFI
RM0041206 	AIR_CONDITION
RM0041206 	FRIDGE
RM0041206 	MINIBAR
RM0041206 	DESK
RM0041206 	SAFE
RM0041206 	HAIRDRYER
RM0041207 	WIFI
RM0041207 	DESK
RM0041207 	MICROWAVE
RM0041207 	MINIBAR
RM0041207 	TV
RM0041207 	IRON
RM0041208 	COFFEE_MAKER
RM0041208 	WIFI
RM0041208 	MINIBAR
RM0041208 	HAIRDRYER
RM0041208 	AIR_CONDITION
RM0041208 	FRIDGE
RM0041208 	TV
RM0041209 	TV
RM0041209 	COFFEE_MAKER
RM0041209 	FRIDGE
RM0041209 	IRON
RM0041209 	DESK
RM0041209 	SAFE
RM0041209 	MICROWAVE
RM0041209 	WIFI
RM0041209 	MINIBAR
RM0041209 	HAIRDRYER
RM0041209 	AIR_CONDITION
RM0041300 	MINIBAR
RM0041300 	COFFEE_MAKER
RM0041300 	MICROWAVE
RM0041300 	IRON
RM0041300 	AIR_CONDITION
RM0041300 	WIFI
RM0041300 	HAIRDRYER
RM0041301 	COFFEE_MAKER
RM0041301 	DESK
RM0041301 	SAFE
RM0041301 	HAIRDRYER
RM0041301 	WIFI
RM0041302 	HAIRDRYER
RM0041302 	TV
RM0041302 	DESK
RM0041302 	WIFI
RM0041302 	MICROWAVE
RM0041302 	FRIDGE
RM0041302 	AIR_CONDITION
RM0041302 	SAFE
RM0041302 	MINIBAR
RM0041302 	COFFEE_MAKER
RM0041303 	WIFI
RM0041303 	TV
RM0041303 	IRON
RM0041303 	COFFEE_MAKER
RM0041303 	FRIDGE
RM0041303 	HAIRDRYER
RM0041303 	SAFE
RM0041303 	AIR_CONDITION
RM0041303 	MINIBAR
RM0041303 	DESK
RM0041303 	MICROWAVE
RM0041304 	TV
RM0041304 	AIR_CONDITION
RM0041304 	MINIBAR
RM0041305 	AIR_CONDITION
RM0041305 	MINIBAR
RM0041305 	SAFE
RM0041305 	COFFEE_MAKER
RM0041306 	HAIRDRYER
RM0041306 	SAFE
RM0041306 	WIFI
RM0041306 	FRIDGE
RM0041306 	AIR_CONDITION
RM0041306 	COFFEE_MAKER
RM0041306 	MINIBAR
RM0041306 	MICROWAVE
RM0041306 	DESK
RM0041307 	TV
RM0041307 	WIFI
RM0041307 	COFFEE_MAKER
RM0041307 	IRON
RM0041307 	AIR_CONDITION
RM0041307 	HAIRDRYER
RM0041307 	SAFE
RM0041307 	MINIBAR
RM0041307 	MICROWAVE
RM0041307 	DESK
RM0041307 	FRIDGE
RM0041308 	MINIBAR
RM0041309 	AIR_CONDITION
RM0041309 	MICROWAVE
RM0041309 	MINIBAR
RM0041309 	HAIRDRYER
RM0041309 	FRIDGE
RM0041309 	WIFI
RM0041309 	TV
RM0041309 	DESK
RM0041309 	IRON
RM0041309 	COFFEE_MAKER
RM0041310 	MINIBAR
RM0041310 	IRON
RM0041311 	AIR_CONDITION
RM0041311 	COFFEE_MAKER
RM0041311 	DESK
RM0041311 	SAFE
RM0041311 	WIFI
RM0041311 	IRON
RM0041311 	HAIRDRYER
RM0041312 	FRIDGE
RM0041313 	MINIBAR
RM0041313 	MICROWAVE
RM0041314 	TV
RM0041314 	COFFEE_MAKER
RM0041314 	FRIDGE
RM0041314 	HAIRDRYER
RM0041314 	WIFI
RM0041315 	DESK
RM0041315 	SAFE
RM0041315 	WIFI
RM0041315 	MICROWAVE
RM0041315 	MINIBAR
RM0041315 	TV
RM0041315 	AIR_CONDITION
RM0041400 	SAFE
RM0041401 	HAIRDRYER
RM0041401 	MICROWAVE
RM0041401 	WIFI
RM0041401 	DESK
RM0041401 	TV
RM0041401 	MINIBAR
RM0041402 	COFFEE_MAKER
RM0041403 	FRIDGE
RM0041403 	COFFEE_MAKER
RM0041403 	SAFE
RM0041403 	MICROWAVE
RM0041403 	HAIRDRYER
RM0041403 	WIFI
RM0041403 	AIR_CONDITION
RM0041403 	MINIBAR
RM0041403 	DESK
RM0041403 	IRON
RM0041403 	TV
RM0041404 	DESK
RM0041404 	FRIDGE
RM0041404 	SAFE
RM0041404 	AIR_CONDITION
RM0041404 	MINIBAR
RM0041404 	COFFEE_MAKER
RM0041404 	MICROWAVE
RM0041404 	HAIRDRYER
RM0041404 	IRON
RM0041404 	TV
RM0041405 	FRIDGE
RM0041405 	WIFI
RM0041405 	IRON
RM0041405 	MINIBAR
RM0041405 	TV
RM0041405 	HAIRDRYER
RM0041406 	HAIRDRYER
RM0041406 	WIFI
RM0041406 	DESK
RM0041406 	MINIBAR
RM0041406 	IRON
RM0041406 	MICROWAVE
RM0041406 	COFFEE_MAKER
RM0041407 	TV
RM0041407 	MINIBAR
RM0041407 	WIFI
RM0041407 	HAIRDRYER
RM0041407 	IRON
RM0041408 	WIFI
RM0041408 	AIR_CONDITION
RM0041408 	SAFE
RM0041408 	MICROWAVE
RM0041408 	DESK
RM0041408 	TV
RM0041408 	HAIRDRYER
RM0041408 	FRIDGE
RM0041408 	COFFEE_MAKER
RM0041408 	MINIBAR
RM0041409 	MICROWAVE
RM0041409 	HAIRDRYER
RM0041409 	FRIDGE
RM0041409 	MINIBAR
RM0041409 	IRON
RM0041409 	WIFI
RM0041409 	SAFE
RM0041409 	DESK
RM0041409 	AIR_CONDITION
RM0041409 	COFFEE_MAKER
RM0041500 	MINIBAR
RM0041500 	TV
RM0041500 	DESK
RM0041500 	COFFEE_MAKER
RM0041500 	SAFE
RM0041500 	FRIDGE
RM0041500 	MICROWAVE
RM0041500 	HAIRDRYER
RM0041500 	AIR_CONDITION
RM0041500 	IRON
RM0041501 	FRIDGE
RM0041501 	SAFE
RM0041501 	MINIBAR
RM0041501 	TV
RM0041501 	MICROWAVE
RM0041501 	DESK
RM0041501 	IRON
RM0041501 	AIR_CONDITION
RM0041502 	FRIDGE
RM0041502 	MINIBAR
RM0041502 	IRON
RM0041502 	COFFEE_MAKER
RM0041502 	TV
RM0041502 	HAIRDRYER
RM0041503 	AIR_CONDITION
RM0041503 	FRIDGE
RM0041503 	DESK
RM0041504 	SAFE
RM0041505 	COFFEE_MAKER
RM0041505 	MICROWAVE
RM0041505 	IRON
RM0041505 	MINIBAR
RM0041505 	TV
RM0041505 	SAFE
RM0041505 	FRIDGE
RM0041505 	HAIRDRYER
RM0041505 	DESK
RM0041505 	WIFI
RM0041506 	IRON
RM0041506 	AIR_CONDITION
RM0041506 	MICROWAVE
RM0041507 	AIR_CONDITION
RM0041507 	MINIBAR
RM0041507 	FRIDGE
RM0041507 	DESK
RM0041507 	IRON
RM0041507 	SAFE
RM0041507 	TV
RM0041508 	WIFI
RM0041508 	HAIRDRYER
RM0041508 	COFFEE_MAKER
RM0041508 	AIR_CONDITION
RM0041508 	DESK
RM0041509 	AIR_CONDITION
RM0041509 	DESK
RM0041510 	MINIBAR
RM0041510 	IRON
RM0041510 	FRIDGE
RM0041510 	MICROWAVE
RM0041510 	COFFEE_MAKER
RM0041511 	COFFEE_MAKER
RM0041511 	WIFI
RM0041511 	MINIBAR
RM0041511 	HAIRDRYER
RM0041511 	DESK
RM0041511 	MICROWAVE
RM0041511 	IRON
RM0041511 	TV
RM0041511 	AIR_CONDITION
RM0041511 	FRIDGE
RM0041511 	SAFE
RM0041600 	AIR_CONDITION
RM0041600 	COFFEE_MAKER
RM0041601 	HAIRDRYER
RM0041601 	MICROWAVE
RM0041601 	IRON
RM0041601 	TV
RM0041602 	COFFEE_MAKER
RM0041602 	WIFI
RM0041602 	FRIDGE
RM0041602 	SAFE
RM0041602 	HAIRDRYER
RM0041602 	MINIBAR
RM0041602 	TV
RM0041602 	AIR_CONDITION
RM0041602 	IRON
RM0041602 	MICROWAVE
RM0041603 	TV
RM0041603 	AIR_CONDITION
RM0041603 	WIFI
RM0041603 	IRON
RM0041604 	DESK
RM0041605 	COFFEE_MAKER
RM0041605 	FRIDGE
RM0041605 	AIR_CONDITION
RM0041606 	SAFE
RM0041606 	MICROWAVE
RM0041606 	TV
RM0041606 	WIFI
RM0041606 	DESK
RM0041606 	COFFEE_MAKER
RM0041606 	IRON
RM0041606 	AIR_CONDITION
RM0041607 	FRIDGE
RM0041607 	SAFE
RM0041607 	TV
RM0041607 	AIR_CONDITION
RM0041607 	DESK
RM0041607 	MINIBAR
RM0041608 	IRON
RM0041608 	MICROWAVE
RM0041609 	COFFEE_MAKER
RM0041609 	DESK
RM0041609 	TV
RM0041609 	MINIBAR
RM0041609 	FRIDGE
RM0041609 	SAFE
RM0041609 	HAIRDRYER
RM0041609 	MICROWAVE
RM0041609 	AIR_CONDITION
RM0041609 	WIFI
RM0041609 	IRON
RM0041610 	WIFI
RM0041610 	DESK
RM0041610 	IRON
RM0041610 	TV
RM0041610 	SAFE
RM0041610 	MINIBAR
RM0041611 	MICROWAVE
RM0041611 	WIFI
RM0041612 	FRIDGE
RM0041613 	SAFE
RM0041613 	DESK
RM0041613 	AIR_CONDITION
RM0041614 	HAIRDRYER
RM0041614 	MINIBAR
RM0041614 	COFFEE_MAKER
RM0041614 	TV
RM0041614 	FRIDGE
RM0041614 	SAFE
RM0041615 	TV
RM0041615 	HAIRDRYER
RM0041615 	MINIBAR
RM0041615 	SAFE
RM0041615 	MICROWAVE
RM0041615 	WIFI
RM0041615 	DESK
RM0041615 	AIR_CONDITION
RM0041616 	MICROWAVE
RM0041616 	MINIBAR
RM0041616 	SAFE
RM0041616 	HAIRDRYER
RM0041616 	DESK
RM0041616 	AIR_CONDITION
RM0041616 	FRIDGE
RM0041617 	WIFI
RM0041617 	FRIDGE
RM0041617 	HAIRDRYER
RM0041617 	IRON
RM0041617 	MICROWAVE
RM0041618 	SAFE
RM0041618 	TV
RM0041618 	COFFEE_MAKER
RM0041618 	DESK
RM0041618 	AIR_CONDITION
RM0041618 	MINIBAR
RM0041618 	IRON
RM0041618 	HAIRDRYER
RM0041618 	MICROWAVE
RM0041700 	IRON
RM0041701 	WIFI
RM0041701 	SAFE
RM0041701 	COFFEE_MAKER
RM0041701 	HAIRDRYER
RM0041702 	SAFE
RM0041702 	FRIDGE
RM0041702 	AIR_CONDITION
RM0041702 	DESK
RM0041702 	TV
RM0041702 	MINIBAR
RM0041702 	MICROWAVE
RM0041702 	IRON
RM0041702 	HAIRDRYER
RM0041703 	HAIRDRYER
RM0041703 	SAFE
RM0041703 	TV
RM0041703 	DESK
RM0041704 	HAIRDRYER
RM0041704 	COFFEE_MAKER
RM0041704 	WIFI
RM0041704 	AIR_CONDITION
RM0041705 	COFFEE_MAKER
RM0041705 	HAIRDRYER
RM0041705 	WIFI
RM0041705 	TV
RM0041705 	SAFE
RM0041705 	FRIDGE
RM0041705 	MICROWAVE
RM0041706 	HAIRDRYER
RM0041706 	SAFE
RM0041706 	WIFI
RM0041706 	IRON
RM0041706 	FRIDGE
RM0041706 	TV
RM0041706 	AIR_CONDITION
RM0041706 	MICROWAVE
RM0041706 	MINIBAR
RM0041706 	DESK
RM0041707 	IRON
RM0041707 	MICROWAVE
RM0041707 	FRIDGE
RM0041707 	AIR_CONDITION
RM0041707 	DESK
RM0041707 	WIFI
RM0041707 	SAFE
RM0041707 	TV
RM0041707 	COFFEE_MAKER
RM0041708 	SAFE
RM0041708 	DESK
RM0041708 	MINIBAR
RM0041708 	HAIRDRYER
RM0041708 	MICROWAVE
RM0041709 	IRON
RM0041709 	TV
RM0041709 	DESK
RM0041710 	IRON
RM0041710 	MINIBAR
RM0041710 	TV
RM0041710 	FRIDGE
RM0041710 	HAIRDRYER
RM0041710 	WIFI
RM0041710 	MICROWAVE
RM0041710 	DESK
RM0041710 	SAFE
RM0041711 	AIR_CONDITION
RM0041711 	TV
RM0041711 	DESK
RM0041711 	MICROWAVE
RM0041711 	COFFEE_MAKER
RM0041711 	MINIBAR
RM0041711 	WIFI
RM0041711 	FRIDGE
RM0041711 	IRON
RM0041711 	HAIRDRYER
RM0041711 	SAFE
RM0041712 	MINIBAR
RM0041712 	MICROWAVE
RM0041712 	DESK
RM0041712 	HAIRDRYER
RM0041712 	IRON
RM0041712 	AIR_CONDITION
RM0041712 	FRIDGE
RM0041713 	HAIRDRYER
RM0041713 	COFFEE_MAKER
RM0041713 	FRIDGE
RM0041714 	HAIRDRYER
RM0041714 	SAFE
RM0041714 	IRON
RM0041714 	MINIBAR
RM0041714 	AIR_CONDITION
RM0041714 	MICROWAVE
RM0041714 	COFFEE_MAKER
RM0041714 	FRIDGE
RM0041714 	TV
RM0041714 	DESK
RM0041715 	COFFEE_MAKER
RM0041715 	IRON
RM0041715 	FRIDGE
RM0041716 	DESK
RM0041716 	AIR_CONDITION
RM0041716 	WIFI
RM0041716 	TV
RM0041717 	COFFEE_MAKER
RM0041717 	TV
RM0041718 	MINIBAR
RM0041718 	AIR_CONDITION
RM0041718 	HAIRDRYER
RM0041718 	WIFI
RM0041718 	IRON
RM0041718 	SAFE
RM0041718 	TV
RM0041718 	COFFEE_MAKER
RM0041718 	DESK
RM0041718 	FRIDGE
RM0041718 	MICROWAVE
RM0041719 	AIR_CONDITION
RM0041719 	IRON
RM0041719 	HAIRDRYER
RM0041719 	MINIBAR
RM0041719 	WIFI
RM0041719 	COFFEE_MAKER
RM0041719 	DESK
RM0041800 	SAFE
RM0041800 	WIFI
RM0041801 	MICROWAVE
RM0041801 	SAFE
RM0041801 	MINIBAR
RM0041801 	TV
RM0041801 	HAIRDRYER
RM0041801 	DESK
RM0041801 	FRIDGE
RM0041801 	AIR_CONDITION
RM0041801 	COFFEE_MAKER
RM0041801 	IRON
RM0041801 	WIFI
RM0041802 	AIR_CONDITION
RM0041802 	IRON
RM0041802 	COFFEE_MAKER
RM0041803 	AIR_CONDITION
RM0041803 	MICROWAVE
RM0041803 	FRIDGE
RM0041803 	IRON
RM0041803 	DESK
RM0041804 	DESK
RM0041804 	AIR_CONDITION
RM0041804 	IRON
RM0041805 	FRIDGE
RM0041805 	COFFEE_MAKER
RM0041805 	MICROWAVE
RM0041805 	IRON
RM0041805 	HAIRDRYER
RM0041805 	TV
RM0041805 	DESK
RM0041806 	IRON
RM0041806 	HAIRDRYER
RM0041806 	TV
RM0041806 	COFFEE_MAKER
RM0041806 	MINIBAR
RM0041806 	AIR_CONDITION
RM0041807 	COFFEE_MAKER
RM0041807 	TV
RM0041807 	MINIBAR
RM0041807 	FRIDGE
RM0041807 	IRON
RM0041807 	SAFE
RM0041807 	DESK
RM0041807 	AIR_CONDITION
RM0041808 	WIFI
RM0041809 	MICROWAVE
RM0041809 	MINIBAR
RM0041809 	AIR_CONDITION
RM0041809 	WIFI
RM0041809 	HAIRDRYER
RM0041809 	COFFEE_MAKER
RM0041809 	IRON
RM0041809 	SAFE
RM0041809 	TV
RM0041810 	FRIDGE
RM0041810 	COFFEE_MAKER
RM0041810 	MICROWAVE
RM0041810 	IRON
RM0041810 	HAIRDRYER
RM0041811 	WIFI
RM0041811 	HAIRDRYER
RM0041811 	COFFEE_MAKER
RM0041811 	FRIDGE
RM0041811 	TV
RM0041811 	MINIBAR
RM0041812 	HAIRDRYER
RM0041812 	MICROWAVE
RM0041812 	WIFI
RM0041812 	AIR_CONDITION
RM0041812 	TV
RM0041812 	MINIBAR
RM0041812 	COFFEE_MAKER
RM0041812 	SAFE
RM0041813 	WIFI
RM0041813 	DESK
RM0041813 	AIR_CONDITION
RM0041813 	FRIDGE
RM0041813 	MICROWAVE
RM0041813 	COFFEE_MAKER
RM0041813 	SAFE
RM0041813 	IRON
RM0041813 	TV
RM0041814 	WIFI
RM0041814 	COFFEE_MAKER
RM0041814 	MINIBAR
RM0041814 	DESK
RM0041814 	TV
RM0041814 	AIR_CONDITION
RM0041814 	SAFE
RM0041814 	HAIRDRYER
RM0041815 	WIFI
RM0041815 	AIR_CONDITION
RM0041815 	MICROWAVE
RM0041815 	FRIDGE
RM0041816 	FRIDGE
RM0041816 	MICROWAVE
RM0041816 	TV
RM0041816 	DESK
RM0041816 	HAIRDRYER
RM0041817 	SAFE
RM0041817 	WIFI
RM0041817 	IRON
RM0041817 	DESK
RM0041817 	MICROWAVE
RM0041817 	HAIRDRYER
RM0041817 	MINIBAR
RM0041817 	COFFEE_MAKER
RM0041900 	MINIBAR
RM0041900 	COFFEE_MAKER
RM0041901 	FRIDGE
RM0041901 	MINIBAR
RM0041902 	AIR_CONDITION
RM0041902 	SAFE
RM0041902 	MICROWAVE
RM0041902 	COFFEE_MAKER
RM0041902 	FRIDGE
RM0041902 	IRON
RM0041902 	TV
RM0041902 	DESK
RM0041902 	HAIRDRYER
RM0041903 	SAFE
RM0041903 	FRIDGE
RM0041903 	WIFI
RM0041903 	MICROWAVE
RM0041903 	DESK
RM0041903 	MINIBAR
RM0041903 	AIR_CONDITION
RM0041903 	COFFEE_MAKER
RM0041903 	TV
RM0041903 	HAIRDRYER
RM0041903 	IRON
RM0041904 	SAFE
RM0041904 	IRON
RM0041904 	HAIRDRYER
RM0041904 	AIR_CONDITION
RM0041904 	COFFEE_MAKER
RM0041904 	MINIBAR
RM0041904 	FRIDGE
RM0041904 	WIFI
RM0041904 	DESK
RM0041905 	FRIDGE
RM0041905 	IRON
RM0041905 	TV
RM0041905 	WIFI
RM0041905 	HAIRDRYER
RM0041905 	MINIBAR
RM0041905 	AIR_CONDITION
RM0041906 	MICROWAVE
RM0041906 	TV
RM0041906 	HAIRDRYER
RM0041906 	COFFEE_MAKER
RM0041906 	FRIDGE
RM0041906 	DESK
RM0041906 	MINIBAR
RM0041906 	WIFI
RM0041906 	AIR_CONDITION
RM0041906 	SAFE
RM0041907 	COFFEE_MAKER
RM0041907 	FRIDGE
RM0041907 	WIFI
RM0041907 	DESK
RM0041907 	IRON
RM0041907 	MICROWAVE
RM0041907 	SAFE
RM0041908 	TV
RM0041908 	MINIBAR
RM0041908 	FRIDGE
RM0041908 	MICROWAVE
RM0041908 	DESK
RM0041909 	MINIBAR
RM0041909 	MICROWAVE
RM0041909 	WIFI
RM0041909 	AIR_CONDITION
RM0041909 	COFFEE_MAKER
RM0041909 	DESK
RM0041910 	MINIBAR
RM0041910 	SAFE
RM0041910 	WIFI
RM0041910 	AIR_CONDITION
RM0041910 	COFFEE_MAKER
RM0041910 	MICROWAVE
RM0041910 	IRON
RM0041910 	TV
RM0041910 	FRIDGE
RM0041910 	HAIRDRYER
RM0041911 	HAIRDRYER
RM0041911 	FRIDGE
RM0041911 	SAFE
RM0041911 	TV
RM0041911 	IRON
RM0041911 	MINIBAR
RM0041911 	WIFI
RM0041911 	AIR_CONDITION
RM0041912 	COFFEE_MAKER
RM0041913 	HAIRDRYER
RM0041913 	MICROWAVE
RM0041913 	SAFE
RM0041914 	FRIDGE
RM0041914 	MICROWAVE
RM0041914 	TV
RM0041914 	COFFEE_MAKER
RM0041914 	DESK
RM0041914 	MINIBAR
RM0041914 	HAIRDRYER
RM0041914 	SAFE
RM0041914 	AIR_CONDITION
RM0041914 	IRON
RM0041915 	SAFE
RM0041916 	TV
RM0041916 	SAFE
RM0041916 	IRON
RM0041916 	MINIBAR
RM0041916 	DESK
RM0041916 	AIR_CONDITION
RM0041916 	FRIDGE
RM0041917 	TV
RM0041917 	SAFE
RM0041917 	DESK
RM0041917 	MINIBAR
RM0041917 	WIFI
RM0041917 	FRIDGE
RM0041917 	AIR_CONDITION
RM0050000 	IRON
RM0050000 	COFFEE_MAKER
RM0050000 	FRIDGE
RM0050001 	IRON
RM0050001 	DESK
RM0050002 	MINIBAR
RM0050002 	FRIDGE
RM0050002 	DESK
RM0050002 	SAFE
RM0050002 	TV
RM0050002 	COFFEE_MAKER
RM0050003 	MICROWAVE
RM0050003 	COFFEE_MAKER
RM0050003 	IRON
RM0050003 	TV
RM0050003 	FRIDGE
RM0050003 	MINIBAR
RM0050004 	DESK
RM0050005 	MINIBAR
RM0050005 	DESK
RM0050005 	WIFI
RM0050005 	SAFE
RM0050005 	TV
RM0050005 	MICROWAVE
RM0050005 	HAIRDRYER
RM0050005 	AIR_CONDITION
RM0050005 	FRIDGE
RM0050006 	IRON
RM0050006 	FRIDGE
RM0050006 	TV
RM0050006 	MICROWAVE
RM0050007 	MICROWAVE
RM0050008 	AIR_CONDITION
RM0050008 	SAFE
RM0050008 	DESK
RM0050008 	FRIDGE
RM0050008 	HAIRDRYER
RM0050009 	WIFI
RM0050009 	MINIBAR
RM0050009 	HAIRDRYER
RM0050009 	COFFEE_MAKER
RM0050009 	TV
RM0050009 	AIR_CONDITION
RM0050009 	IRON
RM0050009 	DESK
RM0050009 	SAFE
RM0050009 	FRIDGE
RM0050010 	HAIRDRYER
RM0050010 	MICROWAVE
RM0050010 	WIFI
RM0050010 	TV
RM0050010 	DESK
RM0050010 	COFFEE_MAKER
RM0050010 	AIR_CONDITION
RM0050010 	IRON
RM0050010 	MINIBAR
RM0050010 	SAFE
RM0050011 	WIFI
RM0050011 	COFFEE_MAKER
RM0050011 	FRIDGE
RM0050011 	MINIBAR
RM0050011 	DESK
RM0050011 	MICROWAVE
RM0050012 	COFFEE_MAKER
RM0050012 	MICROWAVE
RM0050012 	SAFE
RM0050012 	MINIBAR
RM0050013 	MINIBAR
RM0050013 	TV
RM0050013 	DESK
RM0050013 	SAFE
RM0050100 	SAFE
RM0050100 	FRIDGE
RM0050100 	MICROWAVE
RM0050100 	TV
RM0050100 	AIR_CONDITION
RM0050101 	WIFI
RM0050101 	COFFEE_MAKER
RM0050101 	MINIBAR
RM0050101 	MICROWAVE
RM0050101 	HAIRDRYER
RM0050101 	DESK
RM0050101 	FRIDGE
RM0050101 	IRON
RM0050101 	TV
RM0050101 	SAFE
RM0050101 	AIR_CONDITION
RM0050102 	SAFE
RM0050102 	IRON
RM0050102 	COFFEE_MAKER
RM0050102 	DESK
RM0050102 	MICROWAVE
RM0050102 	HAIRDRYER
RM0050102 	WIFI
RM0050102 	TV
RM0050103 	COFFEE_MAKER
RM0050103 	TV
RM0050104 	TV
RM0050104 	COFFEE_MAKER
RM0050104 	WIFI
RM0050104 	HAIRDRYER
RM0050104 	FRIDGE
RM0050104 	MICROWAVE
RM0050104 	AIR_CONDITION
RM0050104 	DESK
RM0050105 	DESK
RM0050105 	SAFE
RM0050105 	MICROWAVE
RM0050105 	HAIRDRYER
RM0050105 	MINIBAR
RM0050105 	WIFI
RM0050105 	AIR_CONDITION
RM0050105 	TV
RM0050105 	COFFEE_MAKER
RM0050105 	IRON
RM0050106 	MINIBAR
RM0050106 	HAIRDRYER
RM0050106 	SAFE
RM0050107 	IRON
RM0050107 	AIR_CONDITION
RM0050107 	MICROWAVE
RM0050107 	FRIDGE
RM0050107 	COFFEE_MAKER
RM0050107 	MINIBAR
RM0050108 	WIFI
RM0050109 	AIR_CONDITION
RM0050110 	FRIDGE
RM0050110 	HAIRDRYER
RM0050110 	AIR_CONDITION
RM0050110 	MICROWAVE
RM0050110 	DESK
RM0050110 	TV
RM0050110 	WIFI
RM0050110 	SAFE
RM0050110 	COFFEE_MAKER
RM0050111 	TV
RM0050111 	DESK
RM0050112 	SAFE
RM0050112 	IRON
RM0050112 	TV
RM0050112 	FRIDGE
RM0050113 	FRIDGE
RM0050113 	MICROWAVE
RM0050113 	TV
RM0050113 	DESK
RM0050113 	AIR_CONDITION
RM0050114 	SAFE
RM0050114 	HAIRDRYER
RM0050114 	AIR_CONDITION
RM0050114 	TV
RM0050114 	MICROWAVE
RM0050114 	COFFEE_MAKER
RM0050114 	IRON
RM0050114 	MINIBAR
RM0050114 	FRIDGE
RM0050114 	DESK
RM0050114 	WIFI
RM0050115 	COFFEE_MAKER
RM0050115 	MINIBAR
RM0050115 	WIFI
RM0050115 	SAFE
RM0050115 	DESK
RM0050115 	FRIDGE
RM0050115 	IRON
RM0050115 	HAIRDRYER
RM0050115 	MICROWAVE
RM0050115 	AIR_CONDITION
RM0050115 	TV
RM0050116 	AIR_CONDITION
RM0050116 	MICROWAVE
RM0050116 	FRIDGE
RM0050117 	DESK
RM0050117 	SAFE
RM0050117 	COFFEE_MAKER
RM0050117 	AIR_CONDITION
RM0050117 	WIFI
RM0050117 	TV
RM0050117 	HAIRDRYER
RM0050117 	MICROWAVE
RM0050117 	IRON
RM0050117 	MINIBAR
RM0050200 	MINIBAR
RM0050200 	MICROWAVE
RM0050200 	TV
RM0050200 	DESK
RM0050200 	WIFI
RM0050200 	HAIRDRYER
RM0050200 	COFFEE_MAKER
RM0050200 	IRON
RM0050200 	SAFE
RM0050200 	AIR_CONDITION
RM0050200 	FRIDGE
RM0050201 	COFFEE_MAKER
RM0050201 	DESK
RM0050201 	MICROWAVE
RM0050201 	SAFE
RM0050201 	MINIBAR
RM0050201 	TV
RM0050201 	HAIRDRYER
RM0050201 	FRIDGE
RM0050201 	WIFI
RM0050201 	AIR_CONDITION
RM0050202 	MICROWAVE
RM0050202 	FRIDGE
RM0050202 	SAFE
RM0050202 	MINIBAR
RM0050202 	COFFEE_MAKER
RM0050202 	TV
RM0050202 	WIFI
RM0050202 	HAIRDRYER
RM0050202 	DESK
RM0050202 	IRON
RM0050203 	AIR_CONDITION
RM0050203 	HAIRDRYER
RM0050203 	DESK
RM0050203 	FRIDGE
RM0050203 	IRON
RM0050203 	SAFE
RM0050203 	COFFEE_MAKER
RM0050203 	MINIBAR
RM0050203 	WIFI
RM0050204 	COFFEE_MAKER
RM0050204 	HAIRDRYER
RM0050204 	SAFE
RM0050204 	MINIBAR
RM0050204 	MICROWAVE
RM0050204 	AIR_CONDITION
RM0050204 	IRON
RM0050204 	WIFI
RM0050204 	DESK
RM0050204 	FRIDGE
RM0050205 	COFFEE_MAKER
RM0050205 	SAFE
RM0050205 	MICROWAVE
RM0050205 	WIFI
RM0050205 	FRIDGE
RM0050205 	AIR_CONDITION
RM0050205 	MINIBAR
RM0050206 	DESK
RM0050206 	MICROWAVE
RM0050206 	FRIDGE
RM0050206 	HAIRDRYER
RM0050206 	IRON
RM0050206 	TV
RM0050206 	AIR_CONDITION
RM0050206 	WIFI
RM0050206 	SAFE
RM0050206 	MINIBAR
RM0050206 	COFFEE_MAKER
RM0050207 	MICROWAVE
RM0050207 	AIR_CONDITION
RM0050207 	TV
RM0050207 	FRIDGE
RM0050207 	WIFI
RM0050207 	SAFE
RM0050208 	MINIBAR
RM0050208 	MICROWAVE
RM0050208 	TV
RM0050208 	COFFEE_MAKER
RM0050208 	AIR_CONDITION
RM0050208 	HAIRDRYER
RM0050208 	IRON
RM0050209 	HAIRDRYER
RM0050209 	IRON
RM0050209 	WIFI
RM0050209 	DESK
RM0050209 	SAFE
RM0050209 	MINIBAR
RM0050209 	TV
RM0050209 	COFFEE_MAKER
RM0050209 	MICROWAVE
RM0050209 	AIR_CONDITION
RM0050209 	FRIDGE
RM0050210 	DESK
RM0050210 	MICROWAVE
RM0050210 	TV
RM0050210 	MINIBAR
RM0050210 	WIFI
RM0050210 	HAIRDRYER
RM0050210 	COFFEE_MAKER
RM0050210 	AIR_CONDITION
RM0050210 	IRON
RM0050210 	FRIDGE
RM0050300 	WIFI
RM0050301 	IRON
RM0050301 	MICROWAVE
RM0050301 	SAFE
RM0050302 	DESK
RM0050302 	MINIBAR
RM0050302 	MICROWAVE
RM0050302 	SAFE
RM0050302 	AIR_CONDITION
RM0050303 	TV
RM0050303 	HAIRDRYER
RM0050303 	IRON
RM0050303 	MICROWAVE
RM0050303 	COFFEE_MAKER
RM0050303 	FRIDGE
RM0050303 	DESK
RM0050303 	MINIBAR
RM0050303 	SAFE
RM0050303 	AIR_CONDITION
RM0050304 	TV
RM0050304 	MICROWAVE
RM0050304 	COFFEE_MAKER
RM0050304 	HAIRDRYER
RM0050304 	MINIBAR
RM0050304 	AIR_CONDITION
RM0050304 	SAFE
RM0050304 	FRIDGE
RM0050304 	WIFI
RM0050304 	DESK
RM0050305 	WIFI
RM0050305 	TV
RM0050305 	HAIRDRYER
RM0050305 	DESK
RM0050305 	FRIDGE
RM0050305 	COFFEE_MAKER
RM0050306 	HAIRDRYER
RM0050306 	DESK
RM0050306 	TV
RM0050306 	MINIBAR
RM0050306 	AIR_CONDITION
RM0050306 	COFFEE_MAKER
RM0050306 	IRON
RM0050307 	AIR_CONDITION
RM0050307 	MICROWAVE
RM0050307 	SAFE
RM0050307 	WIFI
RM0050307 	FRIDGE
RM0050307 	HAIRDRYER
RM0050308 	FRIDGE
RM0050308 	TV
RM0050308 	DESK
RM0050308 	SAFE
RM0050308 	MICROWAVE
RM0050308 	AIR_CONDITION
RM0050308 	HAIRDRYER
RM0050308 	WIFI
RM0050309 	MICROWAVE
RM0050309 	SAFE
RM0050309 	AIR_CONDITION
RM0050309 	DESK
RM0050310 	AIR_CONDITION
RM0050310 	FRIDGE
RM0050310 	WIFI
RM0050310 	SAFE
RM0050310 	HAIRDRYER
RM0050310 	MICROWAVE
RM0050311 	MINIBAR
RM0050311 	COFFEE_MAKER
RM0050311 	SAFE
RM0050311 	MICROWAVE
RM0050311 	AIR_CONDITION
RM0050311 	DESK
RM0050311 	IRON
RM0050311 	TV
RM0050311 	HAIRDRYER
RM0050311 	FRIDGE
RM0050311 	WIFI
RM0050312 	MINIBAR
RM0050312 	DESK
RM0050312 	MICROWAVE
RM0050312 	IRON
RM0050312 	AIR_CONDITION
RM0050312 	HAIRDRYER
RM0050312 	SAFE
RM0050312 	TV
RM0050312 	COFFEE_MAKER
RM0050312 	FRIDGE
RM0050400 	COFFEE_MAKER
RM0050400 	TV
RM0050400 	MICROWAVE
RM0050400 	MINIBAR
RM0050400 	AIR_CONDITION
RM0050400 	IRON
RM0050400 	DESK
RM0050401 	COFFEE_MAKER
RM0050401 	TV
RM0050401 	MINIBAR
RM0050401 	IRON
RM0050401 	WIFI
RM0050401 	SAFE
RM0050401 	HAIRDRYER
RM0050401 	DESK
RM0050402 	HAIRDRYER
RM0050402 	IRON
RM0050402 	MICROWAVE
RM0050402 	COFFEE_MAKER
RM0050402 	WIFI
RM0050402 	MINIBAR
RM0050402 	DESK
RM0050402 	TV
RM0050402 	SAFE
RM0050403 	MICROWAVE
RM0050403 	TV
RM0050403 	HAIRDRYER
RM0050403 	MINIBAR
RM0050403 	AIR_CONDITION
RM0050404 	DESK
RM0050404 	COFFEE_MAKER
RM0050404 	TV
RM0050405 	WIFI
RM0050405 	MINIBAR
RM0050405 	HAIRDRYER
RM0050405 	FRIDGE
RM0050405 	COFFEE_MAKER
RM0050405 	DESK
RM0050405 	SAFE
RM0050405 	MICROWAVE
RM0050405 	IRON
RM0050406 	FRIDGE
RM0050406 	MINIBAR
RM0050406 	SAFE
RM0050406 	IRON
RM0050406 	WIFI
RM0050406 	TV
RM0050407 	IRON
RM0050407 	WIFI
RM0050407 	FRIDGE
RM0050407 	SAFE
RM0050408 	WIFI
RM0050408 	DESK
RM0050408 	AIR_CONDITION
RM0050408 	HAIRDRYER
RM0050408 	MICROWAVE
RM0050408 	TV
RM0050408 	IRON
RM0050408 	MINIBAR
RM0050408 	SAFE
RM0050409 	COFFEE_MAKER
RM0050409 	HAIRDRYER
RM0050409 	FRIDGE
RM0050409 	IRON
RM0050409 	AIR_CONDITION
RM0050409 	MINIBAR
RM0050410 	WIFI
RM0050410 	DESK
RM0050410 	HAIRDRYER
RM0050410 	MINIBAR
RM0050410 	FRIDGE
RM0050410 	IRON
RM0050410 	MICROWAVE
RM0050410 	SAFE
RM0050410 	COFFEE_MAKER
RM0050410 	TV
RM0050410 	AIR_CONDITION
RM0050411 	FRIDGE
RM0050411 	SAFE
RM0050411 	COFFEE_MAKER
RM0050411 	MICROWAVE
RM0050411 	WIFI
RM0050411 	TV
RM0050412 	TV
RM0050412 	FRIDGE
RM0050412 	COFFEE_MAKER
RM0050412 	IRON
RM0050412 	AIR_CONDITION
RM0050412 	SAFE
RM0050412 	MINIBAR
RM0050412 	WIFI
RM0050412 	HAIRDRYER
RM0050412 	DESK
RM0050413 	SAFE
RM0050413 	TV
RM0050413 	DESK
RM0050413 	FRIDGE
RM0050413 	WIFI
RM0050413 	IRON
RM0050413 	COFFEE_MAKER
RM0050413 	AIR_CONDITION
RM0050413 	HAIRDRYER
RM0050500 	SAFE
RM0050500 	MINIBAR
RM0050500 	HAIRDRYER
RM0050500 	IRON
RM0050500 	COFFEE_MAKER
RM0050500 	TV
RM0050500 	MICROWAVE
RM0050500 	AIR_CONDITION
RM0050500 	DESK
RM0050500 	FRIDGE
RM0050500 	WIFI
RM0050501 	AIR_CONDITION
RM0050501 	IRON
RM0050501 	MINIBAR
RM0050501 	DESK
RM0050501 	SAFE
RM0050502 	MINIBAR
RM0050502 	IRON
RM0050502 	MICROWAVE
RM0050502 	COFFEE_MAKER
RM0050502 	AIR_CONDITION
RM0050503 	WIFI
RM0050503 	MICROWAVE
RM0050503 	AIR_CONDITION
RM0050503 	IRON
RM0050504 	WIFI
RM0050504 	MINIBAR
RM0050504 	DESK
RM0050504 	AIR_CONDITION
RM0050504 	HAIRDRYER
RM0050504 	FRIDGE
RM0050504 	MICROWAVE
RM0050505 	MINIBAR
RM0050505 	SAFE
RM0050505 	TV
RM0050505 	FRIDGE
RM0050505 	WIFI
RM0050505 	AIR_CONDITION
RM0050505 	IRON
RM0050506 	TV
RM0050506 	HAIRDRYER
RM0050507 	IRON
RM0050507 	TV
RM0050507 	DESK
RM0050507 	HAIRDRYER
RM0050507 	FRIDGE
RM0050507 	SAFE
RM0050508 	SAFE
RM0050508 	DESK
RM0050508 	HAIRDRYER
RM0050508 	TV
RM0050508 	MICROWAVE
RM0050508 	COFFEE_MAKER
RM0050509 	DESK
RM0050509 	IRON
RM0050509 	HAIRDRYER
RM0050509 	TV
RM0050600 	MINIBAR
RM0050600 	WIFI
RM0050600 	IRON
RM0050600 	COFFEE_MAKER
RM0050600 	MICROWAVE
RM0050600 	FRIDGE
RM0050600 	AIR_CONDITION
RM0050600 	SAFE
RM0050600 	TV
RM0050600 	DESK
RM0050601 	WIFI
RM0050601 	IRON
RM0050601 	MICROWAVE
RM0050602 	COFFEE_MAKER
RM0050602 	MINIBAR
RM0050602 	TV
RM0050603 	DESK
RM0050603 	IRON
RM0050603 	MICROWAVE
RM0050603 	TV
RM0050603 	SAFE
RM0050603 	AIR_CONDITION
RM0050603 	FRIDGE
RM0050603 	COFFEE_MAKER
RM0050604 	HAIRDRYER
RM0050604 	FRIDGE
RM0050604 	TV
RM0050604 	DESK
RM0050604 	COFFEE_MAKER
RM0050605 	MICROWAVE
RM0050605 	DESK
RM0050605 	AIR_CONDITION
RM0050605 	COFFEE_MAKER
RM0050605 	IRON
RM0050605 	WIFI
RM0050605 	HAIRDRYER
RM0050606 	MICROWAVE
RM0050606 	COFFEE_MAKER
RM0050606 	WIFI
RM0050606 	SAFE
RM0050606 	MINIBAR
RM0050606 	AIR_CONDITION
RM0050607 	MICROWAVE
RM0050607 	COFFEE_MAKER
RM0050607 	SAFE
RM0050607 	WIFI
RM0050607 	AIR_CONDITION
RM0050607 	FRIDGE
RM0050608 	TV
RM0050608 	AIR_CONDITION
RM0050608 	IRON
RM0050608 	MICROWAVE
RM0050608 	DESK
RM0050608 	HAIRDRYER
RM0050608 	FRIDGE
RM0050608 	SAFE
RM0050608 	WIFI
RM0050608 	MINIBAR
RM0050608 	COFFEE_MAKER
RM0050609 	MICROWAVE
RM0050609 	SAFE
RM0050609 	MINIBAR
RM0050609 	WIFI
RM0050609 	AIR_CONDITION
RM0050609 	TV
RM0050609 	IRON
RM0050609 	HAIRDRYER
RM0050609 	COFFEE_MAKER
RM0050609 	FRIDGE
RM0050610 	MINIBAR
RM0050611 	MINIBAR
RM0050611 	DESK
RM0050612 	MINIBAR
RM0050612 	IRON
RM0050612 	WIFI
RM0050612 	COFFEE_MAKER
RM0050612 	TV
RM0050612 	AIR_CONDITION
RM0050612 	SAFE
RM0050612 	DESK
RM0050612 	HAIRDRYER
RM0050612 	MICROWAVE
RM0050613 	WIFI
RM0050613 	SAFE
RM0050613 	FRIDGE
RM0050613 	IRON
RM0050613 	COFFEE_MAKER
RM0050613 	MICROWAVE
RM0050613 	TV
RM0050613 	AIR_CONDITION
RM0050613 	DESK
RM0050613 	MINIBAR
RM0050613 	HAIRDRYER
RM0050614 	AIR_CONDITION
RM0050614 	DESK
RM0050614 	MINIBAR
RM0050614 	SAFE
RM0050614 	MICROWAVE
RM0050614 	HAIRDRYER
RM0050614 	FRIDGE
RM0050700 	DESK
RM0050700 	IRON
RM0050700 	SAFE
RM0050700 	MINIBAR
RM0050700 	WIFI
RM0050701 	DESK
RM0050701 	MINIBAR
RM0050701 	IRON
RM0050701 	FRIDGE
RM0050702 	MINIBAR
RM0050702 	FRIDGE
RM0050702 	MICROWAVE
RM0050702 	IRON
RM0050702 	DESK
RM0050702 	COFFEE_MAKER
RM0050703 	FRIDGE
RM0050704 	HAIRDRYER
RM0050704 	IRON
RM0050704 	MINIBAR
RM0050704 	AIR_CONDITION
RM0050705 	IRON
RM0050706 	MINIBAR
RM0050706 	FRIDGE
RM0050706 	DESK
RM0050706 	SAFE
RM0050706 	COFFEE_MAKER
RM0050706 	HAIRDRYER
RM0050707 	IRON
RM0050707 	TV
RM0050707 	DESK
RM0050707 	HAIRDRYER
RM0050707 	MICROWAVE
RM0050707 	COFFEE_MAKER
RM0050707 	FRIDGE
RM0050707 	AIR_CONDITION
RM0050707 	SAFE
RM0050707 	WIFI
RM0050708 	IRON
RM0050708 	MICROWAVE
RM0050708 	SAFE
RM0050708 	FRIDGE
RM0050708 	MINIBAR
RM0050708 	HAIRDRYER
RM0050708 	DESK
RM0050708 	WIFI
RM0050708 	AIR_CONDITION
RM0050709 	FRIDGE
RM0050709 	MINIBAR
RM0050709 	HAIRDRYER
RM0050709 	COFFEE_MAKER
RM0050710 	MINIBAR
RM0050710 	COFFEE_MAKER
RM0050710 	AIR_CONDITION
RM0050710 	DESK
RM0050710 	SAFE
RM0050710 	WIFI
RM0050710 	FRIDGE
RM0050710 	MICROWAVE
RM0050710 	HAIRDRYER
RM0050711 	SAFE
RM0050711 	HAIRDRYER
RM0050711 	AIR_CONDITION
RM0050711 	WIFI
RM0050711 	TV
RM0050711 	COFFEE_MAKER
RM0050711 	IRON
RM0050711 	MINIBAR
RM0050712 	SAFE
RM0050712 	WIFI
RM0050712 	MICROWAVE
RM0050712 	HAIRDRYER
RM0050712 	DESK
RM0050712 	AIR_CONDITION
RM0050712 	FRIDGE
RM0050712 	COFFEE_MAKER
RM0050713 	AIR_CONDITION
RM0050713 	DESK
RM0050713 	SAFE
RM0050713 	WIFI
RM0050713 	MINIBAR
RM0050713 	COFFEE_MAKER
RM0050713 	FRIDGE
RM0050713 	MICROWAVE
RM0050713 	HAIRDRYER
RM0050714 	IRON
RM0050714 	AIR_CONDITION
RM0050714 	MICROWAVE
RM0050714 	WIFI
RM0050715 	COFFEE_MAKER
RM0050715 	TV
RM0050715 	HAIRDRYER
RM0050715 	IRON
RM0050715 	WIFI
RM0050715 	AIR_CONDITION
RM0050715 	DESK
RM0050715 	MICROWAVE
RM0050715 	FRIDGE
RM0050716 	TV
RM0050717 	DESK
RM0050717 	SAFE
RM0050717 	MICROWAVE
RM0050718 	AIR_CONDITION
RM0050718 	FRIDGE
RM0050718 	DESK
RM0050718 	MINIBAR
RM0050718 	IRON
RM0050718 	HAIRDRYER
RM0050718 	TV
RM0050800 	MINIBAR
RM0050801 	DESK
RM0050801 	TV
RM0050801 	MICROWAVE
RM0050801 	WIFI
RM0050801 	IRON
RM0050801 	COFFEE_MAKER
RM0050801 	MINIBAR
RM0050801 	HAIRDRYER
RM0050801 	FRIDGE
RM0050802 	WIFI
RM0050802 	TV
RM0050802 	FRIDGE
RM0050803 	COFFEE_MAKER
RM0050803 	MINIBAR
RM0050803 	IRON
RM0050803 	DESK
RM0050803 	TV
RM0050803 	WIFI
RM0050804 	MINIBAR
RM0050804 	HAIRDRYER
RM0050805 	SAFE
RM0050805 	COFFEE_MAKER
RM0050805 	AIR_CONDITION
RM0050805 	TV
RM0050805 	MINIBAR
RM0050805 	MICROWAVE
RM0050805 	WIFI
RM0050805 	HAIRDRYER
RM0050805 	IRON
RM0050806 	WIFI
RM0050806 	HAIRDRYER
RM0050806 	IRON
RM0050806 	COFFEE_MAKER
RM0050806 	SAFE
RM0050806 	FRIDGE
RM0050807 	SAFE
RM0050807 	WIFI
RM0050807 	MINIBAR
RM0050807 	AIR_CONDITION
RM0050807 	MICROWAVE
RM0050807 	TV
RM0050807 	FRIDGE
RM0050807 	COFFEE_MAKER
RM0050807 	IRON
RM0050807 	HAIRDRYER
RM0050807 	DESK
RM0050808 	MICROWAVE
RM0050808 	SAFE
RM0050808 	TV
RM0050808 	MINIBAR
RM0050808 	COFFEE_MAKER
RM0050808 	HAIRDRYER
RM0050808 	WIFI
RM0050808 	AIR_CONDITION
RM0050809 	WIFI
RM0050810 	MINIBAR
RM0050810 	SAFE
RM0050810 	AIR_CONDITION
RM0050810 	HAIRDRYER
RM0050810 	FRIDGE
RM0050810 	TV
RM0050811 	WIFI
RM0050811 	HAIRDRYER
RM0050811 	AIR_CONDITION
RM0050811 	FRIDGE
RM0050811 	MINIBAR
RM0050811 	MICROWAVE
RM0050811 	COFFEE_MAKER
RM0050811 	SAFE
RM0050811 	DESK
RM0050812 	COFFEE_MAKER
RM0050812 	FRIDGE
RM0050812 	WIFI
RM0050812 	IRON
RM0050812 	HAIRDRYER
RM0050812 	DESK
RM0050812 	SAFE
RM0050812 	TV
RM0050812 	AIR_CONDITION
RM0050812 	MICROWAVE
RM0050813 	SAFE
RM0050813 	AIR_CONDITION
RM0050813 	HAIRDRYER
RM0050813 	MICROWAVE
RM0050813 	MINIBAR
RM0050813 	IRON
RM0050813 	COFFEE_MAKER
RM0050813 	FRIDGE
RM0050813 	TV
RM0050813 	WIFI
RM0050814 	IRON
RM0050814 	FRIDGE
RM0050815 	COFFEE_MAKER
RM0050815 	HAIRDRYER
RM0050815 	MICROWAVE
RM0050815 	MINIBAR
RM0050815 	AIR_CONDITION
RM0050815 	IRON
RM0050815 	DESK
RM0050815 	SAFE
RM0050815 	WIFI
RM0050815 	TV
RM0050815 	FRIDGE
RM0050816 	HAIRDRYER
RM0050816 	WIFI
RM0050817 	IRON
RM0050817 	TV
RM0050817 	MINIBAR
RM0050817 	AIR_CONDITION
RM0050817 	COFFEE_MAKER
RM0050817 	WIFI
RM0050817 	HAIRDRYER
RM0050817 	SAFE
RM0050817 	FRIDGE
RM0050817 	DESK
RM0050817 	MICROWAVE
RM0050900 	AIR_CONDITION
RM0050900 	TV
RM0050900 	MINIBAR
RM0050901 	FRIDGE
RM0050901 	MICROWAVE
RM0050901 	WIFI
RM0050902 	WIFI
RM0050902 	SAFE
RM0050902 	TV
RM0050903 	COFFEE_MAKER
RM0050903 	HAIRDRYER
RM0050903 	SAFE
RM0050903 	IRON
RM0050903 	DESK
RM0050903 	AIR_CONDITION
RM0050903 	TV
RM0050903 	MINIBAR
RM0050903 	WIFI
RM0050903 	MICROWAVE
RM0050904 	IRON
RM0050904 	MICROWAVE
RM0050904 	FRIDGE
RM0050904 	MINIBAR
RM0050904 	TV
RM0050904 	SAFE
RM0050904 	WIFI
RM0050904 	AIR_CONDITION
RM0050904 	HAIRDRYER
RM0050904 	DESK
RM0050905 	AIR_CONDITION
RM0050905 	HAIRDRYER
RM0050905 	MICROWAVE
RM0050905 	DESK
RM0050905 	TV
RM0050905 	MINIBAR
RM0050905 	WIFI
RM0050905 	FRIDGE
RM0050905 	IRON
RM0050906 	COFFEE_MAKER
RM0050907 	WIFI
RM0050907 	TV
RM0050907 	AIR_CONDITION
RM0050907 	MICROWAVE
RM0050907 	IRON
RM0050907 	DESK
RM0050907 	MINIBAR
RM0050907 	HAIRDRYER
RM0050907 	SAFE
RM0050907 	FRIDGE
RM0050908 	MICROWAVE
RM0050908 	FRIDGE
RM0050909 	IRON
RM0050909 	FRIDGE
RM0050909 	TV
RM0050909 	WIFI
RM0050909 	COFFEE_MAKER
RM0050909 	SAFE
RM0050909 	DESK
RM0050909 	MICROWAVE
RM0050909 	AIR_CONDITION
RM0050909 	MINIBAR
RM0050910 	DESK
RM0050910 	MINIBAR
RM0050910 	IRON
RM0050910 	AIR_CONDITION
RM0050910 	FRIDGE
RM0050910 	COFFEE_MAKER
RM0050910 	SAFE
RM0050911 	IRON
RM0050911 	SAFE
RM0050911 	DESK
RM0050911 	WIFI
RM0050911 	AIR_CONDITION
RM0050911 	FRIDGE
RM0050911 	MINIBAR
RM0050911 	MICROWAVE
RM0050911 	HAIRDRYER
RM0050911 	COFFEE_MAKER
RM0050912 	TV
RM0050912 	SAFE
RM0050912 	DESK
RM0050913 	TV
RM0050914 	HAIRDRYER
RM0050915 	FRIDGE
RM0050915 	SAFE
RM0050915 	HAIRDRYER
RM0050915 	MINIBAR
RM0050915 	DESK
RM0050916 	IRON
RM0050916 	MINIBAR
RM0050916 	MICROWAVE
RM0050916 	DESK
RM0050916 	HAIRDRYER
RM0050916 	AIR_CONDITION
RM0050916 	SAFE
RM0050916 	COFFEE_MAKER
RM0050917 	TV
RM0050917 	COFFEE_MAKER
RM0050917 	MICROWAVE
RM0050917 	SAFE
RM0050917 	DESK
RM0050917 	AIR_CONDITION
RM0050917 	HAIRDRYER
RM0050918 	AIR_CONDITION
RM0050918 	MICROWAVE
RM0050918 	IRON
RM0050918 	DESK
RM0051000 	DESK
RM0051000 	MICROWAVE
RM0051001 	MINIBAR
RM0051001 	HAIRDRYER
RM0051001 	MICROWAVE
RM0051001 	DESK
RM0051001 	SAFE
RM0051001 	AIR_CONDITION
RM0051001 	COFFEE_MAKER
RM0051001 	WIFI
RM0051002 	WIFI
RM0051002 	AIR_CONDITION
RM0051002 	TV
RM0051002 	SAFE
RM0051002 	MINIBAR
RM0051002 	IRON
RM0051002 	MICROWAVE
RM0051003 	MINIBAR
RM0051003 	SAFE
RM0051003 	AIR_CONDITION
RM0051003 	COFFEE_MAKER
RM0051004 	COFFEE_MAKER
RM0051004 	MICROWAVE
RM0051004 	MINIBAR
RM0051004 	TV
RM0051005 	MINIBAR
RM0051005 	HAIRDRYER
RM0051005 	IRON
RM0051005 	AIR_CONDITION
RM0051005 	TV
RM0051006 	SAFE
RM0051006 	TV
RM0051006 	MINIBAR
RM0051007 	AIR_CONDITION
RM0051007 	TV
RM0051007 	FRIDGE
RM0051007 	MICROWAVE
RM0051007 	COFFEE_MAKER
RM0051008 	DESK
RM0051008 	WIFI
RM0051009 	MICROWAVE
RM0051009 	AIR_CONDITION
RM0051009 	DESK
RM0051009 	IRON
RM0051009 	SAFE
RM0051010 	DESK
RM0051010 	WIFI
RM0051010 	COFFEE_MAKER
RM0051010 	MINIBAR
RM0051010 	AIR_CONDITION
RM0051010 	IRON
RM0051010 	SAFE
RM0051010 	TV
RM0051010 	HAIRDRYER
RM0051010 	FRIDGE
RM0051010 	MICROWAVE
RM0051011 	MINIBAR
RM0051011 	IRON
RM0051011 	WIFI
RM0051011 	TV
RM0051011 	COFFEE_MAKER
RM0051011 	MICROWAVE
RM0051011 	SAFE
RM0051011 	AIR_CONDITION
RM0051012 	WIFI
RM0051012 	HAIRDRYER
RM0051012 	DESK
RM0051012 	MICROWAVE
RM0051013 	TV
RM0051014 	DESK
RM0051014 	AIR_CONDITION
RM0051014 	FRIDGE
RM0051014 	MICROWAVE
RM0051014 	SAFE
RM0051014 	MINIBAR
RM0051014 	TV
RM0051014 	HAIRDRYER
RM0051014 	IRON
RM0051014 	COFFEE_MAKER
RM0051015 	SAFE
RM0051015 	WIFI
RM0051015 	AIR_CONDITION
RM0051015 	COFFEE_MAKER
RM0051015 	FRIDGE
RM0051015 	TV
RM0051015 	MICROWAVE
RM0051015 	MINIBAR
RM0051015 	IRON
RM0051100 	WIFI
RM0051100 	FRIDGE
RM0051100 	COFFEE_MAKER
RM0051100 	MICROWAVE
RM0051100 	AIR_CONDITION
RM0051101 	SAFE
RM0051102 	IRON
RM0051102 	COFFEE_MAKER
RM0051102 	AIR_CONDITION
RM0051102 	SAFE
RM0051102 	MINIBAR
RM0051102 	TV
RM0051102 	FRIDGE
RM0051102 	DESK
RM0051102 	MICROWAVE
RM0051102 	HAIRDRYER
RM0051103 	COFFEE_MAKER
RM0051103 	TV
RM0051103 	AIR_CONDITION
RM0051103 	HAIRDRYER
RM0051104 	COFFEE_MAKER
RM0051104 	MINIBAR
RM0051104 	WIFI
RM0051104 	FRIDGE
RM0051104 	SAFE
RM0051104 	HAIRDRYER
RM0051104 	DESK
RM0051104 	IRON
RM0051105 	SAFE
RM0051105 	WIFI
RM0051105 	COFFEE_MAKER
RM0051105 	FRIDGE
RM0051105 	IRON
RM0051105 	MICROWAVE
RM0051105 	AIR_CONDITION
RM0051105 	MINIBAR
RM0051106 	HAIRDRYER
RM0051107 	HAIRDRYER
RM0051107 	AIR_CONDITION
RM0051107 	COFFEE_MAKER
RM0051107 	MINIBAR
RM0051108 	WIFI
RM0051108 	DESK
RM0051108 	IRON
RM0051108 	SAFE
RM0051108 	COFFEE_MAKER
RM0051108 	MICROWAVE
RM0051108 	FRIDGE
RM0051108 	HAIRDRYER
RM0051108 	MINIBAR
RM0051109 	MICROWAVE
RM0051109 	WIFI
RM0051109 	COFFEE_MAKER
RM0051109 	MINIBAR
RM0051109 	AIR_CONDITION
RM0051110 	MINIBAR
RM0051110 	HAIRDRYER
RM0051110 	FRIDGE
RM0051110 	SAFE
RM0051110 	WIFI
RM0051111 	AIR_CONDITION
RM0051111 	DESK
RM0051111 	MICROWAVE
RM0051111 	WIFI
RM0051111 	MINIBAR
RM0051111 	IRON
RM0051111 	TV
RM0051111 	HAIRDRYER
RM0051200 	AIR_CONDITION
RM0051200 	SAFE
RM0051200 	COFFEE_MAKER
RM0051200 	WIFI
RM0051200 	HAIRDRYER
RM0051200 	TV
RM0051201 	SAFE
RM0051201 	COFFEE_MAKER
RM0051201 	TV
RM0051201 	FRIDGE
RM0051201 	MICROWAVE
RM0051201 	HAIRDRYER
RM0051201 	MINIBAR
RM0051202 	TV
RM0051203 	AIR_CONDITION
RM0051203 	MICROWAVE
RM0051203 	MINIBAR
RM0051203 	WIFI
RM0051203 	HAIRDRYER
RM0051203 	SAFE
RM0051203 	IRON
RM0051203 	TV
RM0051204 	WIFI
RM0051205 	COFFEE_MAKER
RM0051205 	WIFI
RM0051205 	TV
RM0051206 	SAFE
RM0051206 	AIR_CONDITION
RM0051206 	TV
RM0051206 	MINIBAR
RM0051206 	FRIDGE
RM0051206 	IRON
RM0051206 	HAIRDRYER
RM0051206 	WIFI
RM0051207 	AIR_CONDITION
RM0051207 	SAFE
RM0051207 	TV
RM0051207 	HAIRDRYER
RM0051207 	COFFEE_MAKER
RM0051207 	MICROWAVE
RM0051207 	WIFI
RM0051207 	MINIBAR
RM0051208 	MICROWAVE
RM0051209 	MICROWAVE
RM0051209 	FRIDGE
RM0051209 	DESK
RM0051210 	SAFE
RM0051210 	AIR_CONDITION
RM0051210 	IRON
RM0051210 	FRIDGE
RM0051210 	HAIRDRYER
RM0051210 	TV
RM0051210 	WIFI
RM0051210 	MINIBAR
RM0051210 	MICROWAVE
RM0051210 	COFFEE_MAKER
RM0051210 	DESK
RM0051211 	MICROWAVE
RM0051211 	MINIBAR
RM0051211 	SAFE
RM0051211 	AIR_CONDITION
RM0051211 	COFFEE_MAKER
RM0051211 	IRON
RM0051211 	FRIDGE
RM0051211 	WIFI
RM0051211 	HAIRDRYER
RM0051211 	DESK
RM0051212 	COFFEE_MAKER
RM0051212 	AIR_CONDITION
RM0051212 	WIFI
RM0051212 	TV
RM0051212 	MICROWAVE
RM0051212 	IRON
RM0051212 	FRIDGE
RM0051212 	MINIBAR
RM0051213 	AIR_CONDITION
RM0051213 	MICROWAVE
RM0051213 	HAIRDRYER
RM0051213 	SAFE
RM0051213 	FRIDGE
RM0051213 	COFFEE_MAKER
RM0051213 	WIFI
RM0051213 	DESK
RM0051213 	MINIBAR
RM0051214 	AIR_CONDITION
RM0051215 	FRIDGE
RM0051215 	DESK
RM0051215 	WIFI
RM0051215 	IRON
RM0051215 	MICROWAVE
RM0051215 	COFFEE_MAKER
RM0051215 	SAFE
RM0051215 	MINIBAR
RM0051300 	HAIRDRYER
RM0051300 	TV
RM0051300 	IRON
RM0051300 	SAFE
RM0051301 	SAFE
RM0051302 	WIFI
RM0051302 	DESK
RM0051302 	HAIRDRYER
RM0051302 	SAFE
RM0051302 	MICROWAVE
RM0051302 	COFFEE_MAKER
RM0051302 	FRIDGE
RM0051302 	MINIBAR
RM0051302 	TV
RM0051303 	FRIDGE
RM0051303 	MINIBAR
RM0051303 	HAIRDRYER
RM0051303 	AIR_CONDITION
RM0051303 	TV
RM0051303 	DESK
RM0051303 	WIFI
RM0051303 	COFFEE_MAKER
RM0051304 	TV
RM0051304 	MINIBAR
RM0051304 	COFFEE_MAKER
RM0051305 	FRIDGE
RM0051306 	MINIBAR
RM0051306 	DESK
RM0051306 	SAFE
RM0051306 	HAIRDRYER
RM0051306 	TV
RM0051307 	AIR_CONDITION
RM0051307 	IRON
RM0051307 	MICROWAVE
RM0051307 	SAFE
RM0051307 	FRIDGE
RM0051307 	MINIBAR
RM0051307 	TV
RM0051308 	FRIDGE
RM0051308 	MINIBAR
RM0051308 	HAIRDRYER
RM0051308 	DESK
RM0051308 	MICROWAVE
RM0051308 	IRON
RM0051308 	SAFE
RM0051308 	WIFI
RM0051308 	TV
RM0051308 	AIR_CONDITION
RM0051309 	FRIDGE
RM0051310 	COFFEE_MAKER
RM0051310 	SAFE
RM0051400 	MICROWAVE
RM0051400 	FRIDGE
RM0051400 	DESK
RM0051400 	TV
RM0051400 	SAFE
RM0051400 	COFFEE_MAKER
RM0051400 	MINIBAR
RM0051400 	IRON
RM0051400 	AIR_CONDITION
RM0051400 	WIFI
RM0051401 	AIR_CONDITION
RM0051401 	TV
RM0051402 	SAFE
RM0051402 	MICROWAVE
RM0051403 	AIR_CONDITION
RM0051403 	HAIRDRYER
RM0051404 	DESK
RM0051404 	SAFE
RM0051404 	MICROWAVE
RM0051404 	HAIRDRYER
RM0051404 	FRIDGE
RM0051404 	TV
RM0051404 	AIR_CONDITION
RM0051404 	IRON
RM0051404 	WIFI
RM0051404 	COFFEE_MAKER
RM0051404 	MINIBAR
RM0051405 	WIFI
RM0051405 	MICROWAVE
RM0051405 	TV
RM0051405 	COFFEE_MAKER
RM0051405 	IRON
RM0051405 	SAFE
RM0051405 	HAIRDRYER
RM0051405 	MINIBAR
RM0051405 	FRIDGE
RM0051405 	DESK
RM0051406 	AIR_CONDITION
RM0051406 	WIFI
RM0051406 	HAIRDRYER
RM0051406 	DESK
RM0051406 	MICROWAVE
RM0051406 	MINIBAR
RM0051406 	COFFEE_MAKER
RM0051406 	TV
RM0051406 	SAFE
RM0051407 	MICROWAVE
RM0051407 	HAIRDRYER
RM0051407 	TV
RM0051407 	COFFEE_MAKER
RM0051407 	WIFI
RM0051407 	IRON
RM0051407 	FRIDGE
RM0051407 	DESK
RM0051407 	AIR_CONDITION
RM0051407 	SAFE
RM0051407 	MINIBAR
RM0051408 	COFFEE_MAKER
RM0051408 	SAFE
RM0051408 	FRIDGE
RM0051408 	DESK
RM0051408 	WIFI
RM0051408 	AIR_CONDITION
RM0051408 	IRON
RM0051408 	TV
RM0051408 	MICROWAVE
RM0051408 	MINIBAR
RM0051409 	DESK
RM0051409 	COFFEE_MAKER
RM0051409 	MICROWAVE
RM0051409 	IRON
RM0051409 	AIR_CONDITION
RM0051409 	SAFE
RM0051410 	DESK
RM0051410 	COFFEE_MAKER
RM0051410 	TV
RM0051410 	HAIRDRYER
RM0051410 	AIR_CONDITION
RM0051410 	SAFE
RM0051410 	MICROWAVE
RM0051410 	IRON
RM0051410 	WIFI
RM0051411 	IRON
RM0051411 	AIR_CONDITION
RM0051411 	COFFEE_MAKER
RM0051411 	SAFE
RM0051411 	WIFI
RM0051411 	DESK
RM0051411 	MINIBAR
RM0051411 	TV
RM0051412 	COFFEE_MAKER
RM0051413 	SAFE
RM0051413 	DESK
RM0051413 	FRIDGE
RM0051413 	MICROWAVE
RM0051414 	WIFI
RM0051415 	MINIBAR
RM0051415 	HAIRDRYER
RM0051415 	WIFI
RM0051415 	TV
RM0051415 	DESK
RM0051415 	FRIDGE
RM0051415 	SAFE
RM0051415 	MICROWAVE
RM0051415 	AIR_CONDITION
\.


--
-- TOC entry 3776 (class 0 OID 16995)
-- Dependencies: 233
-- Data for Name: roompricelog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roompricelog (log_id, room_id, old_price, new_price, changed_at) FROM stdin;
1	RM0010000 	465.50	403.33	2025-03-04 15:44:38.378498
\.


--
-- TOC entry 3769 (class 0 OID 16912)
-- Dependencies: 226
-- Data for Name: roomproblem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roomproblem (room_id, problem) FROM stdin;
RM0010001 	Lack of towels
RM0010003 	Dirty linens
RM0010004 	Room not cleaned
RM0010005 	Clogged toilet
RM0010006 	Strong odor in the room
RM0010007 	Power outage
RM0010009 	Clogged toilet
RM0010010 	Broken showerhead
RM0010011 	Damaged furniture
RM0010013 	Strong odor in the room
RM0010100 	Broken air conditioner
RM0010103 	Noisy neighbors
RM0010105 	Broken air conditioner
RM0010107 	Uncomfortable bed
RM0010108 	Unclean room
RM0010109 	Broken air conditioner
RM0010110 	Leaking faucet
RM0010111 	Unpleasant temperature
RM0010114 	No hot water
RM0010200 	Uncomfortable bed
RM0010202 	No hot water
RM0010203 	Power outage
RM0010204 	Noisy neighbors
RM0010208 	Leaking faucet
RM0010211 	Strong odor in the room
RM0010300 	Broken air conditioner
RM0010302 	Damaged furniture
RM0010303 	Leaking faucet
RM0010304 	No hot water
RM0010307 	Lack of towels
RM0010308 	Unclean room
RM0010311 	Unpleasant temperature
RM0010312 	Strong odor in the room
RM0010313 	Noisy plumbing
RM0010400 	Broken air conditioner
RM0010401 	Key card not working
RM0010402 	Noisy plumbing
RM0010407 	Clogged toilet
RM0010408 	Unpleasant temperature
RM0010409 	Non-functioning TV
RM0010411 	Uncomfortable bed
RM0010412 	Clogged toilet
RM0010414 	Noisy plumbing
RM0010415 	Broken window
RM0010501 	Noisy neighbors
RM0010503 	Unclean room
RM0010505 	Unpleasant temperature
RM0010509 	Broken window
RM0010514 	Clogged toilet
RM0010517 	Damaged furniture
RM0010600 	Broken window
RM0010601 	Dirty linens
RM0010602 	Noisy neighbors
RM0010603 	Broken showerhead
RM0010605 	Dirty linens
RM0010609 	Damaged furniture
RM0010610 	Broken window
RM0010700 	Broken showerhead
RM0010701 	Unclean room
RM0010702 	Damaged furniture
RM0010704 	No hot water
RM0010706 	Wi-Fi not working
RM0010707 	Non-functioning TV
RM0010710 	Broken showerhead
RM0010711 	Dirty linens
RM0010712 	Unpleasant temperature
RM0010800 	Unpleasant temperature
RM0010801 	Damaged furniture
RM0010803 	Key card not working
RM0010804 	Unclean room
RM0010805 	Power outage
RM0010815 	Leaking faucet
RM0010906 	Damaged furniture
RM0010908 	Noisy neighbors
RM0010910 	Lack of towels
RM0010911 	Uncomfortable bed
RM0011002 	Broken showerhead
RM0011006 	Clogged toilet
RM0011007 	Unclean room
RM0011008 	Broken window
RM0011011 	Noisy neighbors
RM0011013 	Dirty linens
RM0011015 	Non-functioning TV
RM0011017 	No hot water
RM0011100 	Unpleasant temperature
RM0011101 	Wi-Fi not working
RM0011105 	Unpleasant temperature
RM0011108 	Clogged toilet
RM0011109 	Key card not working
RM0011111 	Unpleasant temperature
RM0011114 	Broken air conditioner
RM0011115 	Lack of towels
RM0011200 	Noisy neighbors
RM0011202 	Lack of towels
RM0011205 	Broken air conditioner
RM0011206 	Broken showerhead
RM0011209 	Wi-Fi not working
RM0011211 	Strong odor in the room
RM0011213 	Lack of towels
RM0011214 	Clogged toilet
RM0011215 	Uncomfortable bed
RM0011216 	No hot water
RM0011217 	Leaking faucet
RM0011300 	Non-functioning TV
RM0011302 	Clogged toilet
RM0011305 	Damaged furniture
RM0011307 	Lack of towels
RM0011308 	Broken air conditioner
RM0011309 	Noisy plumbing
RM0011310 	Damaged furniture
RM0011312 	Room not cleaned
RM0011313 	Strong odor in the room
RM0011315 	Dirty linens
RM0011400 	Non-functioning TV
RM0011401 	Wi-Fi not working
RM0011402 	Unclean room
RM0011403 	Broken air conditioner
RM0011404 	Clogged toilet
RM0011405 	Damaged furniture
RM0011406 	Broken air conditioner
RM0011408 	Noisy plumbing
RM0011409 	Broken air conditioner
RM0011411 	Dirty linens
RM0011500 	Unclean room
RM0011502 	Non-functioning TV
RM0011503 	Leaking faucet
RM0011504 	Damaged furniture
RM0011508 	Leaking faucet
RM0011512 	Dirty linens
RM0011516 	Dirty linens
RM0011601 	Broken showerhead
RM0011602 	Lack of towels
RM0011603 	Damaged furniture
RM0011604 	Strong odor in the room
RM0011605 	Broken air conditioner
RM0011608 	Noisy neighbors
RM0011610 	Power outage
RM0011612 	Uncomfortable bed
RM0011614 	Dirty linens
RM0011616 	Uncomfortable bed
RM0011617 	Non-functioning TV
RM0011700 	Noisy plumbing
RM0011702 	Lack of towels
RM0011703 	Damaged furniture
RM0011706 	Dirty linens
RM0011707 	Dirty linens
RM0011708 	Clogged toilet
RM0011710 	Wi-Fi not working
RM0011711 	Key card not working
RM0011712 	Broken air conditioner
RM0011713 	Unclean room
RM0011802 	Key card not working
RM0011806 	Lack of towels
RM0011807 	Dirty linens
RM0011809 	Broken showerhead
RM0011810 	Non-functioning TV
RM0011901 	Key card not working
RM0011903 	Unclean room
RM0011907 	Noisy plumbing
RM0011908 	Wi-Fi not working
RM0011910 	Broken air conditioner
RM0012000 	Key card not working
RM0012002 	Lack of towels
RM0012003 	Unpleasant temperature
RM0012004 	Wi-Fi not working
RM0012005 	Broken window
RM0012008 	Damaged furniture
RM0012010 	Leaking faucet
RM0012011 	Room not cleaned
RM0012100 	Power outage
RM0012102 	Unpleasant temperature
RM0012104 	Strong odor in the room
RM0012105 	Dirty linens
RM0012106 	No hot water
RM0012109 	Non-functioning TV
RM0012110 	Broken air conditioner
RM0012111 	Dirty linens
RM0012112 	Wi-Fi not working
RM0012201 	Lack of towels
RM0012202 	Broken window
RM0012203 	Strong odor in the room
RM0012204 	Broken showerhead
RM0012205 	Damaged furniture
RM0012206 	Non-functioning TV
RM0012208 	Noisy neighbors
RM0012214 	Wi-Fi not working
RM0012215 	Key card not working
RM0020000 	Non-functioning TV
RM0020006 	Power outage
RM0020007 	Dirty linens
RM0020008 	Noisy plumbing
RM0020009 	Dirty linens
RM0020100 	Noisy plumbing
RM0020103 	Noisy neighbors
RM0020105 	Broken air conditioner
RM0020106 	Unpleasant temperature
RM0020110 	Key card not working
RM0020112 	Strong odor in the room
RM0020113 	Broken air conditioner
RM0020116 	Unpleasant temperature
RM0020118 	Broken window
RM0020200 	Non-functioning TV
RM0020203 	Non-functioning TV
RM0020205 	Damaged furniture
RM0020209 	Clogged toilet
RM0020211 	Leaking faucet
RM0020212 	Unclean room
RM0020213 	Noisy plumbing
RM0020300 	Dirty linens
RM0020301 	Unclean room
RM0020303 	Power outage
RM0020306 	No hot water
RM0020307 	Damaged furniture
RM0020308 	Broken air conditioner
RM0020311 	Strong odor in the room
RM0020401 	Uncomfortable bed
RM0020404 	Wi-Fi not working
RM0020406 	Broken showerhead
RM0020407 	Unclean room
RM0020408 	Wi-Fi not working
RM0020410 	Wi-Fi not working
RM0020500 	Non-functioning TV
RM0020501 	Power outage
RM0020504 	Damaged furniture
RM0020506 	Strong odor in the room
RM0020507 	Dirty linens
RM0020508 	Broken air conditioner
RM0020510 	No hot water
RM0020600 	Unclean room
RM0020601 	Clogged toilet
RM0020605 	Broken showerhead
RM0020609 	Damaged furniture
RM0020611 	No hot water
RM0020612 	Noisy plumbing
RM0020613 	Broken window
RM0020702 	Leaking faucet
RM0020705 	Strong odor in the room
RM0020706 	Dirty linens
RM0020707 	No hot water
RM0020708 	Leaking faucet
RM0020709 	Unclean room
RM0020711 	Dirty linens
RM0020800 	Clogged toilet
RM0020802 	Broken showerhead
RM0020803 	Unclean room
RM0020805 	Non-functioning TV
RM0020807 	Damaged furniture
RM0020808 	Damaged furniture
RM0020810 	Broken showerhead
RM0020811 	Dirty linens
RM0020814 	Non-functioning TV
RM0020815 	Room not cleaned
RM0020816 	Non-functioning TV
RM0020817 	Leaking faucet
RM0020818 	Power outage
RM0020900 	Key card not working
RM0020901 	Wi-Fi not working
RM0020902 	No hot water
RM0020904 	Broken window
RM0020909 	Strong odor in the room
RM0020910 	Room not cleaned
RM0021001 	Strong odor in the room
RM0021008 	Room not cleaned
RM0021013 	Unclean room
RM0021100 	Broken window
RM0021101 	Leaking faucet
RM0021105 	Unclean room
RM0021107 	Non-functioning TV
RM0021108 	Noisy neighbors
RM0021112 	Unpleasant temperature
RM0021115 	Leaking faucet
RM0021117 	Damaged furniture
RM0021118 	Broken air conditioner
RM0021202 	Lack of towels
RM0021203 	Noisy neighbors
RM0021204 	Uncomfortable bed
RM0021206 	Damaged furniture
RM0021210 	Broken window
RM0021213 	Clogged toilet
RM0021214 	Wi-Fi not working
RM0021216 	Wi-Fi not working
RM0021306 	Unclean room
RM0021308 	Non-functioning TV
RM0021400 	Lack of towels
RM0021401 	Room not cleaned
RM0021403 	Broken air conditioner
RM0021408 	Unclean room
RM0021410 	Damaged furniture
RM0021411 	Unclean room
RM0021501 	Noisy neighbors
RM0021502 	Key card not working
RM0021504 	Broken window
RM0021509 	Unclean room
RM0021511 	Lack of towels
RM0021604 	Room not cleaned
RM0021607 	Broken window
RM0021608 	Non-functioning TV
RM0021610 	Broken showerhead
RM0021701 	Non-functioning TV
RM0021702 	Non-functioning TV
RM0021704 	Unpleasant temperature
RM0021705 	Key card not working
RM0021707 	No hot water
RM0021711 	Dirty linens
RM0021712 	Broken showerhead
RM0030000 	Wi-Fi not working
RM0030001 	Wi-Fi not working
RM0030002 	Broken window
RM0030005 	Power outage
RM0030007 	Power outage
RM0030009 	Wi-Fi not working
RM0030010 	Broken air conditioner
RM0030012 	Wi-Fi not working
RM0030013 	Wi-Fi not working
RM0030016 	Key card not working
RM0030100 	No hot water
RM0030101 	Lack of towels
RM0030102 	No hot water
RM0030104 	Key card not working
RM0030106 	Damaged furniture
RM0030107 	Room not cleaned
RM0030114 	Noisy neighbors
RM0030115 	Leaking faucet
RM0030201 	Lack of towels
RM0030202 	Lack of towels
RM0030203 	Dirty linens
RM0030210 	Broken air conditioner
RM0030300 	Wi-Fi not working
RM0030306 	Non-functioning TV
RM0030310 	Uncomfortable bed
RM0030311 	Unclean room
RM0030312 	Damaged furniture
RM0030400 	Wi-Fi not working
RM0030401 	Broken showerhead
RM0030402 	Strong odor in the room
RM0030403 	Power outage
RM0030405 	Unpleasant temperature
RM0030406 	Dirty linens
RM0030408 	Power outage
RM0030410 	Unpleasant temperature
RM0030411 	Wi-Fi not working
RM0030413 	Broken air conditioner
RM0030501 	Unclean room
RM0030502 	Key card not working
RM0030503 	Uncomfortable bed
RM0030504 	Broken air conditioner
RM0030507 	Broken air conditioner
RM0030509 	Clogged toilet
RM0030513 	Lack of towels
RM0030600 	Broken window
RM0030604 	Uncomfortable bed
RM0030605 	Key card not working
RM0030608 	Broken air conditioner
RM0030610 	Damaged furniture
RM0030701 	Non-functioning TV
RM0030702 	Dirty linens
RM0030703 	Uncomfortable bed
RM0030704 	Uncomfortable bed
RM0030705 	No hot water
RM0030708 	Noisy plumbing
RM0030710 	Wi-Fi not working
RM0030713 	Strong odor in the room
RM0030715 	Uncomfortable bed
RM0030716 	Clogged toilet
RM0030800 	Wi-Fi not working
RM0030802 	No hot water
RM0030803 	Power outage
RM0030804 	Unclean room
RM0030805 	Leaking faucet
RM0030808 	Clogged toilet
RM0030811 	Leaking faucet
RM0030812 	Clogged toilet
RM0030813 	Non-functioning TV
RM0030815 	Room not cleaned
RM0030902 	Room not cleaned
RM0030903 	No hot water
RM0030904 	Key card not working
RM0030905 	Damaged furniture
RM0031000 	Wi-Fi not working
RM0031001 	Broken window
RM0031004 	Power outage
RM0031006 	Wi-Fi not working
RM0031007 	Unclean room
RM0031011 	Broken window
RM0031013 	Broken showerhead
RM0031014 	Unclean room
RM0031015 	Noisy neighbors
RM0031016 	Unclean room
RM0031101 	Non-functioning TV
RM0031105 	Lack of towels
RM0031106 	No hot water
RM0031107 	Power outage
RM0031108 	Broken air conditioner
RM0031109 	Broken showerhead
RM0031110 	Leaking faucet
RM0031112 	Wi-Fi not working
RM0031114 	Broken showerhead
RM0031116 	Unclean room
RM0031118 	Non-functioning TV
RM0031200 	Lack of towels
RM0031203 	Uncomfortable bed
RM0031204 	Power outage
RM0031206 	Wi-Fi not working
RM0031207 	Broken window
RM0031211 	Noisy neighbors
RM0031212 	Key card not working
RM0031214 	Non-functioning TV
RM0031216 	Broken showerhead
RM0031301 	Power outage
RM0031302 	Noisy plumbing
RM0031307 	Lack of towels
RM0031309 	Strong odor in the room
RM0031310 	Broken window
RM0031401 	Broken showerhead
RM0031403 	Clogged toilet
RM0031407 	Leaking faucet
RM0031408 	Broken air conditioner
RM0031410 	Leaking faucet
RM0031411 	Room not cleaned
RM0031413 	Noisy plumbing
RM0031414 	Noisy plumbing
RM0031415 	Power outage
RM0031502 	Unclean room
RM0031504 	Leaking faucet
RM0031505 	Power outage
RM0031507 	Clogged toilet
RM0031509 	Damaged furniture
RM0031511 	No hot water
RM0031514 	Leaking faucet
RM0040000 	Damaged furniture
RM0040001 	No hot water
RM0040003 	Lack of towels
RM0040005 	Unpleasant temperature
RM0040007 	Unpleasant temperature
RM0040008 	Key card not working
RM0040009 	Unpleasant temperature
RM0040106 	Damaged furniture
RM0040108 	Key card not working
RM0040110 	Noisy neighbors
RM0040111 	Wi-Fi not working
RM0040112 	Broken window
RM0040113 	Clogged toilet
RM0040115 	Broken window
RM0040200 	Uncomfortable bed
RM0040201 	Damaged furniture
RM0040203 	Wi-Fi not working
RM0040204 	Leaking faucet
RM0040206 	Broken air conditioner
RM0040207 	Key card not working
RM0040303 	Unclean room
RM0040304 	Lack of towels
RM0040305 	Clogged toilet
RM0040306 	Broken window
RM0040308 	Wi-Fi not working
RM0040309 	Room not cleaned
RM0040401 	Broken showerhead
RM0040402 	Wi-Fi not working
RM0040403 	Lack of towels
RM0040404 	Non-functioning TV
RM0040405 	Unclean room
RM0040406 	Strong odor in the room
RM0040407 	Room not cleaned
RM0040408 	Wi-Fi not working
RM0040409 	Noisy plumbing
RM0040410 	Broken air conditioner
RM0040411 	Uncomfortable bed
RM0040412 	Non-functioning TV
RM0040415 	Clogged toilet
RM0040500 	Noisy plumbing
RM0040502 	Unclean room
RM0040505 	Noisy neighbors
RM0040508 	Leaking faucet
RM0040509 	Dirty linens
RM0040510 	Wi-Fi not working
RM0040511 	Lack of towels
RM0040513 	Leaking faucet
RM0040514 	Uncomfortable bed
RM0040515 	Leaking faucet
RM0040516 	Room not cleaned
RM0040601 	Unpleasant temperature
RM0040607 	Uncomfortable bed
RM0040608 	No hot water
RM0040610 	Strong odor in the room
RM0040612 	Key card not working
RM0040615 	Strong odor in the room
RM0040701 	Wi-Fi not working
RM0040702 	Noisy plumbing
RM0040703 	Strong odor in the room
RM0040704 	Strong odor in the room
RM0040705 	Unpleasant temperature
RM0040706 	Unpleasant temperature
RM0040708 	Damaged furniture
RM0040711 	Uncomfortable bed
RM0040712 	Unclean room
RM0040713 	Unclean room
RM0040714 	Key card not working
RM0040801 	Broken showerhead
RM0040806 	Uncomfortable bed
RM0040808 	Uncomfortable bed
RM0040810 	Key card not working
RM0040811 	Broken showerhead
RM0040901 	Noisy neighbors
RM0040904 	Room not cleaned
RM0040910 	Strong odor in the room
RM0041001 	No hot water
RM0041002 	Strong odor in the room
RM0041005 	Unpleasant temperature
RM0041006 	Dirty linens
RM0041008 	Lack of towels
RM0041009 	Noisy plumbing
RM0041010 	Damaged furniture
RM0041011 	Broken showerhead
RM0041014 	Strong odor in the room
RM0041101 	Room not cleaned
RM0041102 	Wi-Fi not working
RM0041103 	Strong odor in the room
RM0041104 	Noisy plumbing
RM0041109 	Wi-Fi not working
RM0041110 	Damaged furniture
RM0041201 	Clogged toilet
RM0041203 	Unpleasant temperature
RM0041209 	Power outage
RM0041301 	Dirty linens
RM0041302 	Strong odor in the room
RM0041306 	Noisy plumbing
RM0041308 	Leaking faucet
RM0041310 	Leaking faucet
RM0041312 	Lack of towels
RM0041313 	Non-functioning TV
RM0041314 	Broken window
RM0041315 	Clogged toilet
RM0041405 	Room not cleaned
RM0041408 	Room not cleaned
RM0041500 	Unpleasant temperature
RM0041501 	Room not cleaned
RM0041503 	Room not cleaned
RM0041505 	Broken showerhead
RM0041507 	Broken window
RM0041508 	Clogged toilet
RM0041509 	Dirty linens
RM0041511 	Uncomfortable bed
RM0041601 	Non-functioning TV
RM0041604 	Lack of towels
RM0041605 	Broken window
RM0041606 	Broken showerhead
RM0041608 	Wi-Fi not working
RM0041610 	Power outage
RM0041612 	Broken air conditioner
RM0041614 	Clogged toilet
RM0041617 	Leaking faucet
RM0041618 	Broken window
RM0041702 	Noisy neighbors
RM0041703 	Wi-Fi not working
RM0041705 	Leaking faucet
RM0041707 	Dirty linens
RM0041710 	Broken window
RM0041712 	No hot water
RM0041713 	Uncomfortable bed
RM0041714 	Leaking faucet
RM0041717 	Broken air conditioner
RM0041718 	Dirty linens
RM0041719 	No hot water
RM0041801 	Unpleasant temperature
RM0041802 	Damaged furniture
RM0041803 	Strong odor in the room
RM0041804 	Room not cleaned
RM0041806 	Dirty linens
RM0041808 	Noisy neighbors
RM0041813 	Unclean room
RM0041900 	Uncomfortable bed
RM0041902 	Leaking faucet
RM0041903 	Damaged furniture
RM0041907 	Clogged toilet
RM0041908 	Uncomfortable bed
RM0041910 	No hot water
RM0041911 	Dirty linens
RM0041913 	Broken showerhead
RM0041917 	Leaking faucet
RM0050004 	Strong odor in the room
RM0050006 	Unclean room
RM0050007 	Lack of towels
RM0050010 	Unpleasant temperature
RM0050012 	Clogged toilet
RM0050100 	Unclean room
RM0050102 	Broken air conditioner
RM0050103 	Clogged toilet
RM0050104 	Strong odor in the room
RM0050105 	Broken showerhead
RM0050108 	Damaged furniture
RM0050109 	Strong odor in the room
RM0050110 	Lack of towels
RM0050112 	Wi-Fi not working
RM0050114 	Key card not working
RM0050115 	Leaking faucet
RM0050201 	Leaking faucet
RM0050202 	Strong odor in the room
RM0050206 	Key card not working
RM0050207 	Uncomfortable bed
RM0050208 	Room not cleaned
RM0050210 	Noisy plumbing
RM0050301 	No hot water
RM0050302 	Room not cleaned
RM0050306 	Noisy neighbors
RM0050311 	Damaged furniture
RM0050400 	Unpleasant temperature
RM0050401 	Non-functioning TV
RM0050403 	Noisy neighbors
RM0050404 	Unpleasant temperature
RM0050407 	Unpleasant temperature
RM0050408 	Room not cleaned
RM0050410 	Noisy neighbors
RM0050411 	Non-functioning TV
RM0050412 	Broken air conditioner
RM0050413 	Uncomfortable bed
RM0050500 	Leaking faucet
RM0050501 	Unpleasant temperature
RM0050503 	Key card not working
RM0050504 	Clogged toilet
RM0050505 	No hot water
RM0050506 	Noisy plumbing
RM0050601 	Unpleasant temperature
RM0050603 	Leaking faucet
RM0050605 	Key card not working
RM0050608 	Lack of towels
RM0050612 	Power outage
RM0050613 	Wi-Fi not working
RM0050700 	Broken air conditioner
RM0050704 	Broken showerhead
RM0050705 	Unclean room
RM0050707 	Unpleasant temperature
RM0050710 	Noisy plumbing
RM0050711 	Damaged furniture
RM0050713 	Non-functioning TV
RM0050715 	Strong odor in the room
RM0050717 	Key card not working
RM0050804 	Leaking faucet
RM0050805 	Room not cleaned
RM0050806 	Unpleasant temperature
RM0050807 	Non-functioning TV
RM0050808 	Damaged furniture
RM0050809 	Noisy neighbors
RM0050810 	Noisy plumbing
RM0050812 	Room not cleaned
RM0050813 	Lack of towels
RM0050814 	Leaking faucet
RM0050817 	Unpleasant temperature
RM0050901 	Dirty linens
RM0050905 	Key card not working
RM0050907 	Strong odor in the room
RM0050908 	Dirty linens
RM0050912 	Power outage
RM0050917 	Unpleasant temperature
RM0051001 	Uncomfortable bed
RM0051005 	Strong odor in the room
RM0051006 	Broken air conditioner
RM0051009 	Key card not working
RM0051010 	Key card not working
RM0051011 	Clogged toilet
RM0051013 	No hot water
RM0051014 	Uncomfortable bed
RM0051015 	Unpleasant temperature
RM0051100 	Noisy neighbors
RM0051102 	Damaged furniture
RM0051104 	Dirty linens
RM0051105 	Non-functioning TV
RM0051106 	Noisy plumbing
RM0051107 	Noisy neighbors
RM0051200 	Noisy neighbors
RM0051202 	Noisy plumbing
RM0051203 	Unclean room
RM0051204 	Broken showerhead
RM0051207 	Room not cleaned
RM0051208 	Lack of towels
RM0051210 	No hot water
RM0051212 	Unpleasant temperature
RM0051213 	Dirty linens
RM0051215 	Wi-Fi not working
RM0051304 	Noisy neighbors
RM0051307 	Broken window
RM0051309 	Power outage
RM0051310 	Noisy plumbing
RM0051402 	Power outage
RM0051404 	Strong odor in the room
RM0051406 	Broken air conditioner
RM0051407 	Damaged furniture
RM0051408 	Damaged furniture
RM0051412 	Noisy neighbors
RM0051413 	Broken showerhead
RM0051414 	Uncomfortable bed
\.


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 232
-- Name: roompricelog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roompricelog_log_id_seq', 1, true);


--
-- TOC entry 3575 (class 2606 OID 16936)
-- Name: booking booking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3552 (class 2606 OID 16821)
-- Name: chainemailaddress chainemailaddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chainemailaddress
    ADD CONSTRAINT chainemailaddress_pkey PRIMARY KEY (chain_id, email_address);


--
-- TOC entry 3554 (class 2606 OID 16832)
-- Name: chainphonenumber chainphonenumber_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chainphonenumber
    ADD CONSTRAINT chainphonenumber_pkey PRIMARY KEY (chain_id, phone_number);


--
-- TOC entry 3580 (class 2606 OID 16957)
-- Name: checkin checkin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin
    ADD CONSTRAINT checkin_pkey PRIMARY KEY (ssn, customer_id, booking_id);


--
-- TOC entry 3573 (class 2606 OID 16930)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3560 (class 2606 OID 16868)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (ssn);


--
-- TOC entry 3556 (class 2606 OID 16846)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id);


--
-- TOC entry 3550 (class 2606 OID 16815)
-- Name: hotelchain hotelchain_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotelchain
    ADD CONSTRAINT hotelchain_pkey PRIMARY KEY (chain_id);


--
-- TOC entry 3558 (class 2606 OID 16857)
-- Name: hotelphonenumber hotelphonenumber_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotelphonenumber
    ADD CONSTRAINT hotelphonenumber_pkey PRIMARY KEY (hotel_id, phone_number);


--
-- TOC entry 3563 (class 2606 OID 16878)
-- Name: manages manages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (ssn, hotel_id);


--
-- TOC entry 3578 (class 2606 OID 16947)
-- Name: rental rental_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_pkey PRIMARY KEY (rental_id);


--
-- TOC entry 3582 (class 2606 OID 16977)
-- Name: rents rents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_pkey PRIMARY KEY (ssn, customer_id, room_id);


--
-- TOC entry 3567 (class 2606 OID 16895)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_id);


--
-- TOC entry 3569 (class 2606 OID 16906)
-- Name: roomamenity roomamenity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomamenity
    ADD CONSTRAINT roomamenity_pkey PRIMARY KEY (room_id, amenity);


--
-- TOC entry 3584 (class 2606 OID 17001)
-- Name: roompricelog roompricelog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roompricelog
    ADD CONSTRAINT roompricelog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3571 (class 2606 OID 16918)
-- Name: roomproblem roomproblem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomproblem
    ADD CONSTRAINT roomproblem_pkey PRIMARY KEY (room_id, problem);


--
-- TOC entry 3576 (class 1259 OID 17009)
-- Name: idx_booking_room_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_booking_room_dates ON public.booking USING btree (room_id, start_date, end_date);


--
-- TOC entry 3561 (class 1259 OID 17006)
-- Name: idx_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employee_id ON public.employee USING btree (ssn);


--
-- TOC entry 3564 (class 1259 OID 17007)
-- Name: idx_room_hotel_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_hotel_id ON public.room USING btree (hotel_id);


--
-- TOC entry 3565 (class 1259 OID 17008)
-- Name: idx_room_price; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_price ON public.room USING btree (price);


--
-- TOC entry 3609 (class 2620 OID 17005)
-- Name: employee delete_manager_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_manager_trigger AFTER DELETE ON public.employee FOR EACH ROW EXECUTE FUNCTION public.delete_manager_from_manages();


--
-- TOC entry 3610 (class 2620 OID 17003)
-- Name: room room_price_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER room_price_update_trigger AFTER UPDATE ON public.room FOR EACH ROW WHEN ((old.price IS DISTINCT FROM new.price)) EXECUTE FUNCTION public.check_price_update();


--
-- TOC entry 3603 (class 2620 OID 17011)
-- Name: hotelchain trg_delete_chain_email_addresses; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_chain_email_addresses AFTER DELETE ON public.hotelchain FOR EACH ROW EXECUTE FUNCTION public.delete_chain_email_addresses();


--
-- TOC entry 3604 (class 2620 OID 17013)
-- Name: hotelchain trg_delete_chain_phone_numbers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_chain_phone_numbers AFTER DELETE ON public.hotelchain FOR EACH ROW EXECUTE FUNCTION public.delete_chain_phone_numbers();


--
-- TOC entry 3606 (class 2620 OID 17025)
-- Name: hotel trg_delete_employees_from_hotel; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_employees_from_hotel AFTER DELETE ON public.hotel FOR EACH ROW EXECUTE FUNCTION public.delete_employees_from_hotel();


--
-- TOC entry 3607 (class 2620 OID 17017)
-- Name: hotel trg_delete_hotel_phone_numbers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_hotel_phone_numbers AFTER DELETE ON public.hotel FOR EACH ROW EXECUTE FUNCTION public.delete_hotel_phone_numbers();


--
-- TOC entry 3605 (class 2620 OID 17015)
-- Name: hotelchain trg_delete_hotels_from_chain; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_hotels_from_chain AFTER DELETE ON public.hotelchain FOR EACH ROW EXECUTE FUNCTION public.delete_hotels_from_chain();


--
-- TOC entry 3611 (class 2620 OID 17019)
-- Name: room trg_delete_room_amenities; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_room_amenities AFTER DELETE ON public.room FOR EACH ROW EXECUTE FUNCTION public.delete_room_amenities();


--
-- TOC entry 3612 (class 2620 OID 17023)
-- Name: room trg_delete_room_problems; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_room_problems AFTER DELETE ON public.room FOR EACH ROW EXECUTE FUNCTION public.delete_room_problems();


--
-- TOC entry 3608 (class 2620 OID 17021)
-- Name: hotel trg_delete_rooms_from_hotel; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_delete_rooms_from_hotel AFTER DELETE ON public.hotel FOR EACH ROW EXECUTE FUNCTION public.delete_rooms_from_hotel();


--
-- TOC entry 3595 (class 2606 OID 16937)
-- Name: booking booking_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3585 (class 2606 OID 16822)
-- Name: chainemailaddress chainemailaddress_chain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chainemailaddress
    ADD CONSTRAINT chainemailaddress_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES public.hotelchain(chain_id) ON DELETE CASCADE;


--
-- TOC entry 3586 (class 2606 OID 16833)
-- Name: chainphonenumber chainphonenumber_chain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chainphonenumber
    ADD CONSTRAINT chainphonenumber_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES public.hotelchain(chain_id) ON DELETE CASCADE;


--
-- TOC entry 3597 (class 2606 OID 16968)
-- Name: checkin checkin_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin
    ADD CONSTRAINT checkin_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking(booking_id) ON DELETE CASCADE;


--
-- TOC entry 3598 (class 2606 OID 16963)
-- Name: checkin checkin_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin
    ADD CONSTRAINT checkin_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3599 (class 2606 OID 16958)
-- Name: checkin checkin_ssn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin
    ADD CONSTRAINT checkin_ssn_fkey FOREIGN KEY (ssn) REFERENCES public.employee(ssn) ON DELETE CASCADE;


--
-- TOC entry 3589 (class 2606 OID 16869)
-- Name: employee employee_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3587 (class 2606 OID 16847)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES public.hotelchain(chain_id) ON DELETE CASCADE;


--
-- TOC entry 3588 (class 2606 OID 16858)
-- Name: hotelphonenumber hotelphonenumber_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotelphonenumber
    ADD CONSTRAINT hotelphonenumber_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3590 (class 2606 OID 16884)
-- Name: manages manages_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manages
    ADD CONSTRAINT manages_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3591 (class 2606 OID 16879)
-- Name: manages manages_ssn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manages
    ADD CONSTRAINT manages_ssn_fkey FOREIGN KEY (ssn) REFERENCES public.employee(ssn) ON DELETE CASCADE;


--
-- TOC entry 3596 (class 2606 OID 16948)
-- Name: rental rental_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3600 (class 2606 OID 16983)
-- Name: rents rents_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3601 (class 2606 OID 16988)
-- Name: rents rents_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id) ON DELETE CASCADE;


--
-- TOC entry 3602 (class 2606 OID 16978)
-- Name: rents rents_ssn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_ssn_fkey FOREIGN KEY (ssn) REFERENCES public.employee(ssn) ON DELETE CASCADE;


--
-- TOC entry 3592 (class 2606 OID 16896)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3593 (class 2606 OID 16907)
-- Name: roomamenity roomamenity_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomamenity
    ADD CONSTRAINT roomamenity_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id) ON DELETE CASCADE;


--
-- TOC entry 3594 (class 2606 OID 16919)
-- Name: roomproblem roomproblem_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomproblem
    ADD CONSTRAINT roomproblem_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id) ON DELETE CASCADE;


-- Completed on 2025-03-30 14:29:18 EDT

--
-- PostgreSQL database dump complete
--

