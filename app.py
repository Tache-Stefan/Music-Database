import oracledb as db
from flask import Flask, render_template, request
from datetime import datetime

app = Flask(__name__)

username = 'C##intro_user'
password = 'mypassword'
hostname = 'localhost'
port = 1521
service_name = 'xe'


def get_date_columns(table_name):
    dsn = db.makedsn(hostname, port, service_name)
    connection = db.connect(user=username, password=password, dsn=dsn)
    cursor = connection.cursor()

    query = """
    SELECT column_name
    FROM all_tab_columns
    WHERE data_type = 'DATE' and table_name = :table_name
    """

    cursor.execute(query, {'table_name': table_name.upper()})
    return [row[0] for row in cursor.fetchall()]


def get_tables():
    dsn = db.makedsn(hostname, port, service_name)
    connection = db.connect(user=username, password=password, dsn=dsn)
    cursor = connection.cursor()
    query = 'SELECT table_name FROM user_tables'
    cursor.execute(query)
    tables = [row[0] for row in cursor.fetchall()]
    tables.append('VIEW_USER_CARDURI')
    tables.append('VIEW_PLAYLISTURI_MELODII')

    cursor.close()
    connection.close()
    return tables


def get_table_data(table_name, sort_column=None, sort_order='ASC'):
    dsn = db.makedsn(hostname, port, service_name=service_name)
    connection = db.connect(user=username, password=password, dsn=dsn)
    cursor = connection.cursor()

    pk_query = """
    SELECT column_name 
    FROM all_cons_columns 
    WHERE constraint_name = (
        SELECT constraint_name 
        FROM all_constraints 
        WHERE table_name = :table_name 
        AND constraint_type = 'P'
    )
    """

    cursor.execute(pk_query, {'table_name': table_name.upper()})
    primary_key_columns = [row[0] for row in cursor.fetchall()]

    if sort_column:
        query = f"SELECT * FROM {table_name} ORDER BY {sort_column} {sort_order}"
    else:
        query = f"SELECT * FROM {table_name}"
    cursor.execute(query)

    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()

    date_columns = get_date_columns(table_name)
    formatted_rows = []
    for row in rows:
        formatted_row = []
        for col, value in zip(columns, row):
            if col in date_columns and value is not None:
                formatted_row.append(value.strftime('%Y-%m-%d'))
            else:
                formatted_row.append(value)
        formatted_rows.append(tuple(formatted_row))

    cursor.close()
    connection.close()

    return columns, formatted_rows, primary_key_columns


@app.route('/')
def home():
    try:
        tables = get_tables()
        return render_template('tables.html', tables=tables)
    except Exception as e:
        return f"Error: {e}"


@app.route('/table/<table_name>')
def table_data(table_name):
    try:
        sort_column = request.args.get('sort_column')
        sort_order = request.args.get('sort_order', 'ASC')

        columns, rows, primary_key_columns = get_table_data(table_name, sort_column, sort_order)
        if table_name == 'VIEW_USER_CARDURI':
            insertable_columns = columns[1:]
        elif table_name == 'VIEW_PLAYLISTURI_MELODII':
            insertable_columns = []
        else:
            insertable_columns = columns

        return render_template(
            'table_data.html',
            table_name=table_name,
            columns=columns,
            insertable_columns=insertable_columns,
            rows=rows,
            sort_column=sort_column,
            sort_order=sort_order,
            primary_key_columns=primary_key_columns,
            zip=zip
        )
    except Exception as e:
        return f"Error: {e}"


@app.route('/table/<table_name>/delete', methods=['POST'])
def delete_row(table_name):
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        connection.autocommit = True
        cursor = connection.cursor()

        pk_query = """
        SELECT column_name 
        FROM all_cons_columns 
        WHERE constraint_name = (
            SELECT constraint_name 
            FROM all_constraints 
            WHERE table_name = :table_name 
            AND constraint_type = 'P'
        )
        """

        cursor.execute(pk_query, {'table_name': table_name.upper()})

        primary_key_columns = [row[0] for row in cursor.fetchall()]
        if table_name == 'VIEW_USER_CARDURI':
            primary_key_columns.append('NR_CARD')

        where_clauses = []
        bind_values = {}
        for pk_column in primary_key_columns:
            value = request.form.get(pk_column)
            where_clauses.append(f"{pk_column} = :{pk_column}")
            bind_values[pk_column] = value

        where_clause = " AND ".join(where_clauses)
        query = f"DELETE FROM {table_name} WHERE {where_clause}"

        cursor.execute(query, bind_values)
        connection.commit()

        affected_rows = cursor.rowcount

        cursor.close()
        connection.close()

        if affected_rows == 0:
            return f"Nu au fost linii sterse din {table_name}. <a href='/table/{table_name}'>Inapoi</a>"
        return f"Rand sters din {table_name}. <a href='/table/{table_name}'>Inapoi</a>"

    except Exception as e:
        return f"Error: {e}"


@app.route('/table/<table_name>/insert', methods=['POST'])
def insert_row(table_name):
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        connection.autocommit = True
        cursor = connection.cursor()

        columns, _, _ = get_table_data(table_name)
        date_columns = get_date_columns(table_name)

        if table_name == 'VIEW_USER_CARDURI':
            insertable_columns = columns[1:]
        else:
            insertable_columns = columns

        bind_values = {}
        for column in insertable_columns:
            value = request.form.get(column)
            bind_values[column] = value

        columns_str = ", ".join(insertable_columns)
        values_str = ", ".join(
            f"TO_DATE(:{column}, 'YYYY-MM-DD')" if column in date_columns else f":{column}"
            for column in insertable_columns
        )

        if table_name == 'MELODIE':
            view = 'ARTIST_MELODIE_VIEW'
        elif table_name == 'PLAYLIST':
            view = 'USER_PLAYLIST_VIEW'
        else:
            view = table_name
        query = f"INSERT INTO {view} ({columns_str}) VALUES ({values_str})"
        cursor.execute(query, bind_values)
        connection.commit()

        cursor.close()
        connection.close()

        return f"Rand inserat in {table_name}. <a href='/table/{table_name}'>Inapoi</a>"

    except Exception as e:
        return f"Error: {e}"


@app.route('/table/<table_name>/edit', methods=['GET'])
def edit_row_form(table_name):
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        connection.autocommit = True
        cursor = connection.cursor()

        pk_query = """
        SELECT column_name 
        FROM all_cons_columns 
        WHERE constraint_name = (
            SELECT constraint_name 
            FROM all_constraints 
            WHERE table_name = :table_name 
            AND constraint_type = 'P'
        )
        """
        cursor.execute(pk_query, {'table_name': table_name.upper()})
        primary_key_columns = [row[0] for row in cursor.fetchall()]

        where_clauses = []
        bind_values = {}
        for pk_column in primary_key_columns:
            value = request.args.get(pk_column)
            if value is None:
                return f"Error: Missing primary key value for {pk_column}."
            where_clauses.append(f"{pk_column} = :{pk_column}")
            bind_values[pk_column] = value

        where_clause = " AND ".join(where_clauses)

        query = f"SELECT * FROM {table_name} WHERE {where_clause}"
        cursor.execute(query, bind_values)
        columns = [col[0] for col in cursor.description]
        row_data = cursor.fetchone()
        formatted_row_data = [item.strftime('%Y-%m-%d') if isinstance(item, datetime) else item for item in row_data]

        cursor.close()
        connection.close()

        return render_template(
            'edit_row.html',
            table_name=table_name,
            columns=columns,
            row_data=formatted_row_data,
            primary_key_columns=primary_key_columns,
            zip=zip
        )
    except Exception as e:
        return f"Error: {e}"


@app.route('/table/<table_name>/update', methods=['POST'])
def update_row(table_name):
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        connection.autocommit = True
        cursor = connection.cursor()

        pk_query = """
        SELECT column_name
        FROM all_cons_columns 
        WHERE constraint_name = (
            SELECT constraint_name 
            FROM all_constraints 
            WHERE table_name = :table_name 
            AND constraint_type = 'P'
        )
        """
        cursor.execute(pk_query, {'table_name': table_name.upper()})
        primary_key_columns = [row[0] for row in cursor.fetchall()]
        date_columns = get_date_columns(table_name)

        set_clauses = []
        where_clauses = []
        bind_values = {}

        for key, value in request.form.items():
            bind_values[key] = value
            if key in primary_key_columns:
                where_clauses.append(f"{key} = :OLD_{key}")
                bind_values[f"OLD_{key}"] = request.form.get(f"OLD_{key}", value)
            if key.startswith('OLD_'):
                continue
            if key in date_columns:
                set_clauses.append(f"{key} = TO_DATE(:{key}, 'YYYY-MM-DD')")
            else:
                set_clauses.append(f"{key} = :{key}")

        set_clause = ", ".join(set_clauses)
        where_clause = " AND ".join(where_clauses)

        query = f"UPDATE {table_name} SET {set_clause} WHERE {where_clause}"

        cursor.execute(query, bind_values)
        connection.commit()

        cursor.close()
        connection.close()

        return f"Linie editata. <a href='/table/{table_name}'>Inapoi</a>"
    except Exception as e:
        return f"Error: {e}"


@app.route('/cerinta_c')
def cerinta_c():
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        cursor = connection.cursor()

        sort_column = request.args.get('sort_column', 'NUME_USER')
        sort_order = request.args.get('sort_order', 'ASC')

        query = f"""
        SELECT u.nume_user, p.nume_playlist, m.nume_melodie
        FROM User_ u
        JOIN Playlist p ON u.email_user = p.email_user
        JOIN Playlist_Melodie pm ON p.id_playlist = pm.id_playlist
        JOIN Melodie m ON pm.id_melodie = m.id_melodie
        WHERE p.data_c > TO_DATE('01-01-2023', 'DD-MM-YYYY') AND m.durata > 180
        ORDER BY {sort_column} {sort_order}
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        columns = [desc[0] for desc in cursor.description]

        return render_template(
            'cerinta_c.html',
            columns=columns,
            rows=rows,
            sort_column=sort_column,
            sort_order=sort_order
        )
    except Exception as e:
        return f"Error: {e}"


@app.route('/cerinta_d')
def cerinta_d():
    try:
        dsn = db.makedsn(hostname, port, service_name=service_name)
        connection = db.connect(user=username, password=password, dsn=dsn)
        cursor = connection.cursor()

        sort_column = request.args.get('sort_column', 'NUME_USER')
        sort_order = request.args.get('sort_order', 'ASC')

        query = f"""
        SELECT u.nume_user, COUNT(p.id_playlist)
        FROM User_ u JOIN Playlist p ON u.email_user = p.email_user
        GROUP BY u.nume_user
        HAVING COUNT(p.id_playlist) > 2
        ORDER BY {sort_column} {sort_order}
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        columns = [desc[0] for desc in cursor.description]

        return render_template(
            'cerinta_d.html',
            columns=columns,
            rows=rows,
            sort_column=sort_column,
            sort_order=sort_order
        )
    except Exception as e:
        return f"Error: {e}"


if __name__ == '__main__':
    app.run(debug=True)
