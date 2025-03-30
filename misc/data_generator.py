import random
import datetime

# Helper functions
def random_date(start, end):
    return start + datetime.timedelta(days=random.randint(0, (end - start).days))
    
def random_ssn():
    return f"{random.randint(100000000, 999999999)}"

# Helper function for generating random customer ID
def random_customer_id():
    return f"CUST{random.randint(1000, 9999)}"
    
def random_phone():
    area_codes = ['416', '437', '905', '289', '613', '705', '519', '647', '905', '226']
    return f"+1-{random.choice(area_codes)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}"

def random_email(name):
    return f"{name.lower().replace(' ', '_')}@hotelsworld.com"

def random_address():
    street_names = [
        'Main St', 'Second St', 'Third St', 'Fourth St', 'Bank St', 'Rideau St', 'King St', 
        'Queen St', 'Wellington St', 'Elgin St', 'Somerset St', 'Catherine St', 'Laurier Ave', 
        'Clyde Ave', 'Isabella St', 'Colonel By Dr', 'Bronson Ave', 'Carling Ave', 'Merivale Rd', 
        'St. Laurent Blvd', 'McArthur Ave', 'Lisgar St', 'Gladstone Ave', 'Hunt Club Rd'
    ]
    neighborhoods = [
        'Centretown', 'The Glebe', 'Byward Market', 'Rockcliffe Park', 'Westboro', 'Old Ottawa East', 
        'Orleans', 'Kanata', 'Barrhaven', 'Nepean', 'Manotick', 'Stittsville', 'New Edinburgh', 
        'Sandy Hill', 'Carleton Heights', 'Carp', 'Alta Vista', 'Little Italy', 'Overbrook', 'Cumberland'
    ]
    
    return f"{random.randint(100, 999)} {random.choice(street_names)}, {random.choice(neighborhoods)}, Ottawa, Ontario, Canada"

def random_name():
    first_names = ["John", "Jane", "Alex", "Emily", "Chris", "Katie", "Michael", "Sarah", "David", "Laura", "James", "Olivia", "Robert", "Sophia", "William", "Grace", "Daniel", "Megan", "Matthew", "Charlotte", "Ethan"]
    last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "White", "Martin"]
    return random.choice(first_names), random.choice(last_names)

# Generate SQL
sql_statements = []

# Hotel Chains
for i in range(1, 6):
    chain_id = f"CH{str(i).zfill(3)}"
    num_hotels = random.randint(15, 25)
    central_office_address = random_address()
    sql_statements.append(f"INSERT INTO HotelChain (chain_id, num_hotels, central_office_address) VALUES ('{chain_id}', {num_hotels}, '{central_office_address}');")
    
    # Chain Email and Phone
    sql_statements.append(f"INSERT INTO ChainEmailAddress (chain_id, email_address) VALUES ('{chain_id}', '{random_email(chain_id)}');")
    sql_statements.append(f"INSERT INTO ChainPhoneNumber (chain_id, phone_number) VALUES ('{chain_id}', '{random_phone()}');")
    
    # Hotels
    for j in range(num_hotels):
        hotel_id = f"HTL{str(i).zfill(3)}{str(j).zfill(2)}"
        address = random_address()
        num_rooms = random.randint(10, 20)
        contact_email = random_email(hotel_id)
        star_category = random.randint(1, 5)
        sql_statements.append(f"INSERT INTO Hotel (hotel_id, chain_id, address, num_rooms, contact_email, star_category) VALUES ('{hotel_id}', '{chain_id}', '{address}', {num_rooms}, '{contact_email}', {star_category});")
        
        # Hotel Phone
        sql_statements.append(f"INSERT INTO HotelPhoneNumber (hotel_id, phone_number) VALUES ('{hotel_id}', '{random_phone()}');")
        
        rando = random.randint(4, 6)
        for _ in range(rando):
            ssn = random_ssn()
            first_name, last_name = random_name()
            address = random_address()
            role = random.choice(['Receptionist', 'Housekeeper', 'Chef', 'Security'])
            sql_statements.append(f"INSERT INTO Employee (SSN, hotel_id, address, role, first_name, last_name) VALUES ('{ssn}', '{hotel_id}', '{address}', '{role}', '{first_name}', '{last_name}');")
            
        # Create 1 manager
        manager_ssn = random_ssn()
        first_name, last_name = random_name()
        address = random_address()
        role = 'Manager'
        sql_statements.append(f"INSERT INTO Employee (SSN, hotel_id, address, role, first_name, last_name) VALUES ('{manager_ssn}', '{hotel_id}', '{address}', '{role}', '{first_name}', '{last_name}');")
        sql_statements.append(f"INSERT INTO Manages (SSN, hotel_id) VALUES ('{manager_ssn}', '{hotel_id}');")
        
        # Rooms
        for k in range(num_rooms):
            room_id = f"RM{str(i).zfill(3)}{str(j).zfill(2)}{str(k).zfill(2)}"
            price = round(random.uniform(100, 500), 2)
            capacity = random.choice(['SINGLE', 'DOUBLE', 'TRIPLE', 'SUITE', 'QUAD'])
            view = random.choice(['City View', 'Garden View', 'Sea View', 'Mountain View', 'Lake View', 'Pool View', 'Forest View', 'River View', 'Courtyard View', 'Skyline View'])
            extendable = random.choice([True, False])
            sql_statements.append(f"INSERT INTO Room (room_id, hotel_id, price, capacity, view, extendable) VALUES ('{room_id}', '{hotel_id}', {price}, '{capacity}', '{view}', {extendable});")
            
            # Room Amenity
            random_value = random.randint(1, 3)
            for m in range(random_value):
                amenities = ['TV', 'AIR_CONDITION', 'FRIDGE', 'MINIBAR', 'SAFE', 'WIFI', 'HAIRDRYER', 'IRON', 'COFFEE_MAKER', 'MICROWAVE', 'DESK']
                for amenity in random.sample(amenities, random.randint(1, len(amenities))):
                    sql_statements.append(f"INSERT INTO RoomAmenity (room_id, amenity) VALUES ('{room_id}', '{amenity}');")
            
            # Room Problem
            if random.choice([True, False]):
                problem = random.choice([
    'Leaking faucet', 'Broken air conditioner', 'Noisy neighbors', 'Clogged toilet', 
    'No hot water', 'Broken showerhead', 'Broken window', 'Power outage', 
    'Damaged furniture', 'Uncomfortable bed', 'Unclean room', 'Lack of towels', 
    'Wi-Fi not working', 'Dirty linens', 'Non-functioning TV', 'Room not cleaned', 
    'Strong odor in the room', 'Key card not working', 'Unpleasant temperature', 'Noisy plumbing'
])
                sql_statements.append(f"INSERT INTO RoomProblem (room_id, problem) VALUES ('{room_id}', '{problem}');")

for _ in range(5):
    customer_id = random_customer_id()
    first_name, last_name = random_name()
    address = random_address()
    registration_date = random_date(datetime.date(2020, 1, 1), datetime.date.today())
    id_type = random.choice(['SSN', 'SIN', 'DRIVING_LICENSE'])
    id_number = random_ssn()
    sql_statements.append(f"INSERT INTO Customer (customer_id, address, first_name, last_name, registration_date, id_type, id_number) VALUES ('{customer_id}', '{address}', '{first_name}', '{last_name}', '{registration_date}', '{id_type}', '{id_number}');")
    
# Print SQL statements
for statement in sql_statements:
    print(statement)