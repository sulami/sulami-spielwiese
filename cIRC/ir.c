#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>

#define VERSION         "0.1"
#define DEFAULTSERVER   "82.96.64.4" /* Freenode */
#define DEFAULTPORT     6667
#define DEFAULTNICK     "sulami"
#define DEFAULTUSER     "sulami 0 * :Robin Schroer"

struct irc_connection {
    int sock;
    char *ip;
    unsigned short port;
    struct sockaddr_in conn;
    char *nick;
    char *user;
};

static struct irc_connection ircc = {
    .sock = 0,
    .ip = DEFAULTSERVER,
    .port = DEFAULTPORT,
    .conn = 0,
    .nick = DEFAULTNICK,
    .user = DEFAULTUSER,
};

/*
 * irc_conn(): Establish a connection to a given server.
 *
 *      Operates on the global struct ircc.
 */
static void irc_conn()
{
    if ((ircc.sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("Error creating socket.\n");
        exit(-1);
    }

    ircc.conn.sin_addr.s_addr = inet_addr(ircc.ip);
    ircc.conn.sin_family = AF_INET;
    ircc.conn.sin_port = htons(ircc.port);

    if (connect(ircc.sock, (struct sockaddr *)&ircc.conn, sizeof(ircc.conn)) < 0) {
        printf("Error connecting to server.\n");
        exit(-2);
    }
}

/*
 * irc_recv(): Receiving loop on a given socket
 */
void *irc_recv()
{
    static char server_msg[2000];

    while(1) {
        recv(ircc.sock, server_msg, 2000, 0);
        printf("%s\n", server_msg);
    }
}

/*
 * irc_send(): Sends a message over a socket
 *
 * TAKES: char *message   = message to send
 */
static void irc_send(char *message)
{
    send(ircc.sock, message, strlen(message), 0);
}

int main(int argc, char *argv[])
{
    int rc;
    pthread_t *thread = NULL;

    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            if (!strcmp(argv[i], "-s")) {
                i++;
                ircc.ip = argv[i];
            } else if (!strcmp(argv[i], "-p")) {
                i++;
                ircc.port = (unsigned short)strtoul(argv[i], NULL, 0);
            } else if (!strcmp(argv[i], "-n")) {
                i++;
                ircc.nick = argv[i];
            } else if (!strcmp(argv[i], "-u")) {
                i++;
                ircc.user = argv[i];
            } else if (!strcmp(argv[i], "--version")) {
                printf("IR.c version %s\n", VERSION);
                return 0;
            }
        }
    }

    irc_send("NICK sulami");
    irc_send("USER sulami 0 * :Robin Schroer");

    rc = pthread_create(thread, 0, irc_recv, 0);

    pthread_exit(NULL);

    shutdown(ircc.sock, 2);

    return 0;
}

