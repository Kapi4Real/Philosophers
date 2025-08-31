#include "philosophers.h"

int main(int argc, char **argv)
{
    t_data data;

    if (!parse_args(&data, argc, argv))
        return (1);
    if (!init_simulation(&data))
        return (1);
    if (!start_threads(&data))
        return (1);

    pthread_join(data.monitor, NULL);

    printf("Simulation initialisée avec %d philosophes\n", data.nb_philos);
    return (0);
}
