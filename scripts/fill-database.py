import psycopg2
from contextlib import closing
from faker import Faker
import random
import math
import datetime

my_faker = Faker()
Faker.seed(1337)
random.seed(1337)
levels = ['economy', 'comfort', 'lux']
MAX_CAPACITY = 6


def rand_russian_letter():
    letters = "абвгежзийклмнопстуфхцчшщэюя"
    return letters[random.randint(0, len(letters) - 1)]


def rand_digit():
    return str(random.randint(0, 9))


def rand_numberplate():
    return rand_russian_letter() + \
           rand_digit() + rand_digit() + rand_digit() + \
           rand_russian_letter() + rand_russian_letter()


def rand_brand():
    brands = ['bmw', 'lada', 'mercedes', 'audi', 'toyota', 'honda', 'opel', 'ford']
    return brands[random.randint(0, len(brands) - 1)]


def gen_car(i):
    return i, rand_brand(), levels[random.randint(0, len(levels) - 1)], \
           random.randint(3, MAX_CAPACITY), rand_numberplate(),


def gen_park(i):
    name = my_faker.word()
    return i, name, name + "@gmail.com"


def gen_address(i):
    x = random.randint(1, 5000)
    y = random.randint(1, 5000)
    country = my_faker.country()
    city = my_faker.city()
    street = my_faker.street_name()
    building = my_faker.building_number()
    return (i, country, city, street, building), (x, y)


def gen_driver(i):
    return i, my_faker.name(), random.randint(1, 10000000)


def gen_user(i):
    return i, my_faker.name(), my_faker.word()


parks = list(map(gen_park, range(1, 100)))
users = list(map(gen_user, range(1, 3000)))
drivers = list(map(gen_driver, range(1, 1000)))
addresses = list(map(gen_address, range(1, 1000)))
cars = list(map(gen_car, range(1, 1000)))


def gen_owned_car(i):
    owner = random.randint(0, len(parks) - 1)
    return i, parks[owner][0], random.randint(500, 1000)


def gen_ride(i):
    payment_types = ['cash', 'card', 'bitcoin']
    src = random.randint(0, len(addresses) - 1)
    dst = random.randint(0, len(addresses) - 1)
    while src == dst:
        dst = random.randint(0, len(addresses) - 1)
    src_id = addresses[src][0][0]
    dst_id = addresses[dst][0][0]
    p1 = addresses[src][1]
    p2 = addresses[dst][1]
    dist = int(math.sqrt((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2))
    payment = payment_types[random.randint(0, len(payment_types) - 1)]
    car = random.randint(0, len(cars) - 1)
    level = levels[random.randint(0, levels.index(cars[car][2]))]
    passengers_cnt = random.randint(1, cars[car][3])
    price = dist * (levels.index(level) + 1)
    driver_id = drivers[random.randint(0, len(drivers) - 1)][0]
    user_id = users[random.randint(0, len(users) - 1)][0]
    length = random.randint(5, 40)
    car_id = cars[car][0]
    start_time = my_faker.date_time_this_month()
    end_time = start_time + datetime.timedelta(minutes=length)
    start_str = start_time.isoformat(sep=' ')
    end_str = end_time.isoformat(sep=' ')
    return i, src_id, dst_id, start_str, end_str, \
           payment, price, level, passengers_cnt, driver_id, car_id, user_id, dist


print('Enter username')
username = input()
print('Enter password')
password = input()
with closing(psycopg2.connect(dbname='taxi',
                              user=username,
                              password=password,
                              host='localhost')) as conn:
    conn.autocommit = True
    with conn.cursor() as cursor:
        for car in cars:
            cursor.execute(
                '''INSERT INTO cars
                (id, brand, level, capacity, numberplate)
                VALUES
                (%s, %s, %s, %s, %s)''',
                car
            )
        for park in parks:
            cursor.execute(
                '''INSERT INTO taxi_parks
                (id, name, email)
                VALUES
                (%s, %s, %s)''',
                park
            )
        for user in users:
            cursor.execute(
                '''SELECT add_user(%s, %s, %s)''',
                user
            )
        for driver in drivers:
            cursor.execute(
                '''INSERT INTO taxi_drivers
                (id, full_name, license_num)
                VALUES
                (%s, %s, %s)''',
                driver
            )
        for address in addresses:
            cursor.execute(
                '''INSERT INTO addresses
                (id, country, city, street, building)
                VALUES
                (%s, %s, %s, %s, %s)''',
                address[0]
            )
        for car_id, *_ in cars:
            owned_car = gen_owned_car(car_id)
            cursor.execute(
                '''INSERT INTO owned_cars
                (car_id, park_id, rent_price)
                VALUES
                (%s, %s, %s)''',
                owned_car
            )
        failed_inerts = 0
        for i in range(1, 6000):
            ride = gen_ride(i)
            try:
                cursor.execute(
                    '''INSERT INTO rides
                    (id, src_id, dst_id, start_time, end_time, payment_type, price,
                    level, passengers_cnt, driver_id, car_id, user_id, distance)
                    VALUES
                    (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                    ride
                )
            except:
                failed_inerts += 1
        print("Failed {} inserts".format(failed_inerts))
