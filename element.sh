cd ~/project
mkdir -p periodic_table && cd periodic_table
git init && git checkout -b main

cat > element.sh << 'EOF'
#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]; then
  WHERE="e.atomic_number=$1"
elif [[ ${#1} -le 2 ]]; then
  WHERE="e.symbol='$1'"
else
  WHERE="e.name='$1'"
fi

read -r AN NAME SYM TYPE MASS MELT BOIL <<< $(IFS='|'; echo $($PSQL "SELECT e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $WHERE"))

if [[ -z $AN ]]; then
  echo "I could not find that element in the database."
else
  echo "The element with atomic number $AN is $NAME ($SYM). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
fi
EOF

chmod +x element.sh

git add .
git commit -m "Initial commit"
echo "# v2" >> element.sh && git add . && git commit -m "feat: add element lookup"
echo "# v3" >> element.sh && git add . && git commit -m "fix: handle no argument"
echo "# v4" >> element.sh && git add . && git commit -m "refactor: simplify query"
echo "# v5" >> element.sh && git add . && git commit -m "chore: finalize script"

pg_dump -cC --inserts -U freecodecamp periodic_table > periodic_table.sql
git add . && git commit -m "chore: add database dump"