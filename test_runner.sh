echo "" > tests.out

for i in {1..11}; do
  NODYNCHECK=1 TYPECHECK=1 bundle exec rspec spec/models/user_spec.rb spec/models/service_spec.rb >> tests.out 2>&1
done
grep "Finished in" tests.out | awk '{print $3}'
