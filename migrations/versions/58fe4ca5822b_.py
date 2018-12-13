"""empty message

Revision ID: 58fe4ca5822b
Revises: 
Create Date: 2018-12-12 23:01:59.993635

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '58fe4ca5822b'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('projects', sa.Column('rep_id', sa.Integer(), nullable=True))
    op.create_foreign_key(None, 'projects', 'employees', ['rep_id'], ['id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'projects', type_='foreignkey')
    op.drop_column('projects', 'rep_id')
    # ### end Alembic commands ###
