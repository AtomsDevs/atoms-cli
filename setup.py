from setuptools import setup, find_packages

setup(
    name='Atoms CLI',
    version='1.0.0',
    packages=find_packages(),
    url='https://github.com/AtomsDevs/atoms-cli',
    license='GPL-3.0-only',
    author='Mirko Brombin',
    author_email='send@mirko.pm',
    description='Atoms CLI allows you to manage your Atoms installation',
    entry_points={
        'console_scripts': [
            'atoms-cli=atoms_cli.cli:main',
        ]
    },
    install_requires=[
        'atoms-core',
        'tabluate'
    ]
)