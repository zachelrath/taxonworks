admin = User.create!(
  name: 'John Doe',
  email: 'admin@example.com',
  password: 'taxonworks',
  password_confirmation: 'taxonworks',
  is_administrator: true,
  self_created: true
)

user = User.create!(
  name: 'John Doe',
  email: 'user@example.com',
  password: 'taxonworks',
  password_confirmation: 'taxonworks',
  is_administrator: false,
  by: admin
)

project = Project.create(
  name: "test_project",
  by: admin
)

ProjectMember.create!(
  project: project,
  user: admin,
  by: admin
)

taxon_name = Protonym.create!(
  name: "Testidae",
  rank_class: Ranks.lookup(:iczn, 'Family'),
  parent: project.root_taxon_name,
  project: project,
  by: admin
)

otu = Otu.create!(
  name: 'test_otu',
  taxon_name: taxon_name,
  project: project,
  by: admin
)

# Verify we don't run all queues
ShouldNotRunJob.perform_later(otu)
