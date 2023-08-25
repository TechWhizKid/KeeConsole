import os
import click
import shutil


@click.command()
@click.argument('target_path')
@click.option('-c', '--clean', is_flag=True, help='Clean the contents without deleting the folder')
def delete(target_path, clean):
    """Delete a file or folder."""
    if os.path.isfile(target_path):
        if clean:
            click.echo("Clean option is not applicable for a file.")
        else:
            try:
                os.remove(target_path)
                click.echo(f"File '{target_path}' has been deleted successfully.")
            except FileNotFoundError:
                click.echo(f"File '{target_path}' does not exist.")
            except Exception as e:
                click.echo(f"An error occurred while deleting the file '{target_path}': {str(e)}")
    elif os.path.isdir(target_path):
        if clean:
            clean_folder(target_path)
        else:
            try:
                shutil.rmtree(target_path)
                click.echo(f"Folder '{target_path}' has been deleted successfully.")
            except FileNotFoundError:
                click.echo(f"Folder '{target_path}' does not exist.")
            except Exception as e:
                click.echo(f"An error occurred while deleting the folder '{target_path}': {str(e)}")
    else:
        click.echo(f"'{target_path}' is neither a file nor a folder.")


def clean_file(file_path):
    try:
        with open(file_path, 'wb'):
            pass
        click.echo(f"File '{file_path}' has been cleaned successfully.")
    except FileNotFoundError:
        click.echo(f"File '{file_path}' does not exist.")
    except Exception as e:
        click.echo(f"An error occurred while cleaning the file '{file_path}': {str(e)}")


def clean_folder(folder_path):
    try:
        for root, dirs, files in os.walk(folder_path, topdown=False):
            for file in files:
                file_path = os.path.join(root, file)
                clean_file(file_path)

        click.echo(f"Folder '{folder_path}' has been cleaned successfully.")
    except FileNotFoundError:
        click.echo(f"Folder '{folder_path}' does not exist.")
    except Exception as e:
        click.echo(f"An error occurred while cleaning the folder '{folder_path}': {str(e)}")


if __name__ == '__main__':
    delete()
